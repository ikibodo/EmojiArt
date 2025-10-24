//
//  EmojiArtDocument.swift
//  Emoji Art
//
//  Created by N L on 18. 7. 2025..
//

import SwiftUI
import UniformTypeIdentifiers
// View Model
extension UTType {
    static let emojiart = UTType(exportedAs: "edu.stanford.cs193p.emojiart")
}

class EmojiArtDocument: ReferenceFileDocument {
    func snapshot(contentType: UTType) throws -> Data {
        try emojiArt.json()
    }
    
    func fileWrapper(snapshot: Data, configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: snapshot)
    }
    
    static var readableContentTypes: [UTType] {
        [.emojiart]
    }
    
    required init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            emojiArt = try EmojiArt(json: data)
        } else {
            throw CocoaError(.fileReadCorruptFile)
        }
    }
    
    typealias Emoji = EmojiArt.Emoji
    
    @Published private var emojiArt = EmojiArt() {
        didSet {
            if emojiArt.background != oldValue.background {
                Task {
                    await fetchBackgroundImage()
                }
            }
        }
    }
    
    init(){ }
    
    var emojis: [Emoji] {
        emojiArt.emojis
    }
    
    var bbox: CGRect {
        var bbox = CGRect.zero
        for emoji in emojiArt.emojis {
            bbox = bbox.union(emoji.bbox)
        }
        if let backgroundSize = background.uiImage?.size {
            bbox = bbox.union(CGRect(center: .zero, size: backgroundSize))
        }
        return bbox
    }
    
    @Published var background: Background = .none
    
    // MARK: - Background Image
    @MainActor
    private func fetchBackgroundImage() async {
        if let url = emojiArt.background {
            background = .fetching(url)
            do {
                let image = try await fetchUIImage(from: url)
                if url == emojiArt.background {
                    background = .found(image)
                }
            } catch {
                background = .failed("Couldn't set background: \(error.localizedDescription)")
            }
        } else {
            background = .none
        }
    }
    
    private func fetchUIImage(from url: URL) async throws -> UIImage {
        let (data, _) = try await URLSession.shared.data(from: url)
        if let uiImage = UIImage(data: data) {
            return uiImage
        } else {
            throw FetchError.badImageData
        }
    }
    
    enum FetchError: Error {
        case badImageData
    }
    
    enum Background {
        case none
        case fetching(URL)
        case found(UIImage)
        case failed(String)
        
        var uiImage: UIImage? {
            switch self {
            case .found(let uiImage): return uiImage
                default : return nil
            }
        }
        
        var urlBeingFetched: URL? {
            switch self {
            case .fetching(let url): return url
            default : return nil
            }
        }
        
        var isFetching: Bool {
            urlBeingFetched != nil
        }
        
        var failureReason: String? {
            switch self {
            case .failed(let reason): return reason
            default : return nil
            }
        }
    }
    
    // MARK: - Undo
    
    private func undoablyPerform(_ action: String, with undoManager: UndoManager? = nil, doit: () -> Void) {
        objectWillChange.send() 
        let oldEmojiArt = emojiArt
        doit()
        undoManager?.registerUndo(withTarget: self) { myself in
            myself.undoablyPerform(action, with: undoManager) {
                myself.emojiArt = oldEmojiArt
            }
        }
        undoManager?.setActionName(action)
    }
    
    // MARK: - Intent(s)
    
    func setBackground(_ url: URL?, undoWith undoManager: UndoManager? = nil) {
        undoablyPerform("Set Background", with: undoManager) {
            emojiArt.background = url
        }
    }
    
    func setBackground(_ data: Data, undoWith undoManager: UndoManager? = nil) {
        guard let dataURL = URL.imageDataURL(from: data) else { return }
        setBackground(dataURL, undoWith: undoManager)
    }
    
    func addEmoji(_ emoji: String, at position: Emoji.Position, size: CGFloat, undoWith undoManager: UndoManager? = nil) {
        undoablyPerform("Add \(emoji)", with: undoManager) {
            emojiArt.addEmoji(emoji, at: position, size: Int(size))
        }
    }
    
    func move(_ emoji: Emoji, by offset: CGOffset, undoWith undoManager: UndoManager? = nil) {
        undoablyPerform("Move \(emoji)", with: undoManager) {
            let dx = Int(offset.width.rounded())
            let dy = Int(offset.height.rounded())
            guard dx != 0 || dy != 0 else { return }
            let p = emojiArt[emoji].position
            emojiArt[emoji].position = .init(x: p.x + dx, y: p.y - dy)
        }
    }

    func resize(_ emoji: Emoji, by scale: CGFloat, undoWith undoManager: UndoManager? = nil) {
        undoablyPerform("Resize \(emoji)", with: undoManager) {
            emojiArt[emoji].size = Int(CGFloat(emojiArt[emoji].size) * scale)
        }
    }
    
    func resize(emojiWithId id: Emoji.ID, by scale: CGFloat, undoWith undoManager: UndoManager? = nil) {
        if let emoji = emojiArt[id] {
            resize(emoji, by: scale, undoWith: undoManager)
        }
    }
    
    func remove(emojiWithId id: Emoji.ID, undoWith undoManager: UndoManager? = nil) {
        undoablyPerform("Delete Emoji", with: undoManager) {
            emojiArt.remove(emojiWithId: id)
        }
    }

    func removeEmojis(_ ids: Set<Emoji.ID>, undoWith undoManager: UndoManager? = nil) {
        undoablyPerform("Delete Emojis", with: undoManager) {
            emojiArt.removeEmojis(withIDs: ids)
        }
    }
    
    func moveEmojis(_ ids: Set<Emoji.ID>, by offset: CGOffset, undoWith um: UndoManager? = nil) {
        undoablyPerform("Move Emojis", with: um) {
            let dx = Int(offset.width.rounded())
            let dy = Int(offset.height.rounded())
            guard dx != 0 || dy != 0 else { return }
            for id in ids {
                if let e = emojiArt[id] {
                    let p = e.position
                    emojiArt[e].position = .init(
                        x: p.x + dx,
                        y: p.y - dy 
                    )
                }
            }
        }
    }

    func resizeEmojis(_ ids: Set<Emoji.ID>, by scale: CGFloat, undoWith undoManager: UndoManager? = nil) {
        undoablyPerform("Resize Emojis", with: undoManager) {
            for id in ids { resize(emojiWithId: id, by: scale) }
        }
    }
    
    // MARK: - Z-Order

    func bringToFront(_ ids: Set<Emoji.ID>, undoWith undoManager: UndoManager? = nil) {
        guard !ids.isEmpty else { return }
        undoablyPerform("Bring To Front", with: undoManager) {
            emojiArt.bringToFront(ids)
        }
    }

    func sendToBack(_ ids: Set<Emoji.ID>, undoWith undoManager: UndoManager? = nil) {
        guard !ids.isEmpty else { return }
        undoablyPerform("Send To Back", with: undoManager) {
            emojiArt.sendToBack(ids)
        }
    }
}

extension EmojiArt.Emoji {
    var font: Font {
        Font.system(size: CGFloat(size))
    }
    
    var bbox: CGRect {
        CGRect(
            center: position.in(nil),
            size: CGSize(width: CGFloat(size), height: CGFloat(size))
        )
    }
}

extension EmojiArt.Emoji.Position {
    func `in`(_ geometry: GeometryProxy?) -> CGPoint {
        let center = geometry?.frame(in: .local).center ?? .zero
        return CGPoint(x: center.x + CGFloat(x), y: center.y - CGFloat(y))
    }
}
