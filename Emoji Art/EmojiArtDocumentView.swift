//
//  EmojiArtDocumentView.swift
//  Emoji Art
//
//  Created by N L on 21. 7. 2025..
//

import SwiftUI
import Photos
// View
struct EmojiArtDocumentView: View {
    @Environment(\.undoManager) var undoManager
    
    @StateObject var paletteStore = PaletteStore(named: "Shared")
    
    typealias Emoji = EmojiArt.Emoji
    
    @ObservedObject var document: EmojiArtDocument
    
    @State private var selection = Set<Emoji.ID>()
    @State private var selectionDrag: CGSize = .zero
    
    @ScaledMetric var paletteEmojiSize: CGFloat = 40
    
    @State private var showBackgroundFailureAlert = false
    @State private var zoom: CGFloat = 1
    @State private var pan: CGOffset = .zero
    @State private var showDeleteAlert = false
    @State private var emojiToDelete: Emoji.ID? = nil
    @State private var singleDrag: CGSize = .zero
    @State private var singleDraggingID: Emoji.ID? = nil
    @State private var marqueeStart: CGPoint? = nil
    @State private var marqueeRect: CGRect = .zero
    @State private var exportThumbnail: Image? = nil
    @State private var canvasSize: CGSize = .zero
    @State private var showSavedToast = false
    
    @GestureState private var gestureZoom: CGFloat = 1
    @GestureState private var gesturePan: CGOffset = .zero
    @GestureState private var selectionPinch: CGFloat = 1
    
    var body: some View {
        VStack(spacing: 0) {
            documentBody
            PaletteChooser()
                .font(.system(size: paletteEmojiSize))
                .padding(.horizontal)
                .scrollIndicators(.hidden)
        }
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                UndoButton()
                SendToBackButton(document: document, selection: $selection)
                BringToFrontButton(document: document, selection: $selection)
                DeleteButton(document: document, selection: $selection)
                ChooseBackgroundButton(document: document)
                PasteBackgroundButton(document: document)
                ShareExportButton(
                    item: renderPNG(for: canvasSize),
                    preview: exportThumbnail
                )
                SaveToPhotosButton(content: {
                    exportCanvas(size: canvasSize)
                }, size: canvasSize) {
                    showSavedToast = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        showSavedToast = false
                    }
                }
            }
        }
        .environmentObject(paletteStore)
    }
    
    private var documentBody: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white
                if document.background.isFetching {
                    ProgressView()
                        .scaleEffect(2)
                        .tint(.blue)
                        .position(Emoji.Position.zero.in(geometry))
                }
                documentContents(in: geometry)
                    .scaleEffect(zoom * gestureZoom)
                    .offset(pan + gesturePan)
                    .highPriorityGesture(
                        emojiDragGesture(in: geometry),
                        including: selection.isEmpty ? .subviews : .gesture
                    )
                if marqueeStart != nil {
                    Rectangle()
                        .path(in: marqueeRect)
                        .stroke(Color.blue, lineWidth: 1)
                        .background(Color.blue.opacity(0.1))
                }
                if showSavedToast {
                    Text("Saved to Photos")
                        .padding(.horizontal, 12).padding(.vertical, 8)
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .padding(.bottom, 36)
                }
            }
            .animation(.easeInOut(duration: 0.25), value: showSavedToast)
            .onAppear { canvasSize = geometry.size }
            .onChange(of: geometry.size) { _, newSize in
                canvasSize = newSize
            }
            .contentShape(Rectangle())
            .onTapGesture {
                selection.removeAll()
                selectionDrag = .zero
            }
            .highPriorityGesture(selection.isEmpty ? nil : selectedPinchGesture)
            .gesture(selection.isEmpty ? marqueeGesture(in: geometry) : nil)
            .gesture(selection.isEmpty ? panGesture.simultaneously(with: zoomGesture) : nil)
            .onTapGesture(count: 2) {
                zoomToFit(document.bbox, in: geometry)
            }
            .dropDestination(for: Sturldata.self) { sturldatas, location in
                return drop(sturldatas, at: location, in: geometry)
            }
            .onChange(of: document.background.failureReason) { _, reason in
                showBackgroundFailureAlert = (reason != nil)
            }
            .onChange(of: document.background.uiImage) { _, uiImage in
                zoomToFit(uiImage?.size, in: geometry)
            }
            .task(id: document.bbox) {
                let rect = document.bbox
                let screen = geometry.size.width * geometry.size.height
                guard rect.width * rect.height > screen * 0.4 else { return }
                zoomToFit(rect, in: geometry)
            }
            .alert("Set Background",
                   isPresented: $showBackgroundFailureAlert,
                   presenting: document.background.failureReason,
                   actions: { reason in
                Button("OK", role: .cancel) { }
            },
                   message: { reason in
                Text(reason)
            }
            )
            .alert("Delete this emoji?", isPresented: $showDeleteAlert) {
                Button("Delete", role: .destructive) {
                    if let id = emojiToDelete {
                        document.removeEmojis([id], undoWith: undoManager)
                        selection.remove(id)
                    }
                }
                Button("Cancel", role: .cancel) { }
            }
        }
    }
    
    private func zoomToFit(_ size: CGSize?, in geometry: GeometryProxy) {
        if let size {
            zoomToFit(CGRect(center: .zero, size: size), in: geometry)
        }
    }
    
    private func zoomToFit(_ rect: CGRect, in geometry: GeometryProxy) {
        withAnimation {
            if rect.size.width > 0, rect.size.height > 0,
               geometry.size.width > 0, geometry.size.height > 0 {
                let hZoom = geometry.size.width / rect.size.width
                let vZoom = geometry.size.height / rect.size.height
                zoom = min(hZoom, vZoom)
                pan = CGOffset(
                    width: -rect.midX * zoom,
                    height: -rect.midY * zoom
                )
            }
        }
    }
    
    private var zoomGesture: some Gesture {
        MagnificationGesture()
            .updating($gestureZoom) { inMotionPinchScale, gestureZoom, _ in
                gestureZoom = inMotionPinchScale
            }
            .onEnded { endingPinchScale in
                zoom *= endingPinchScale
            }
    }
    
    private var panGesture: some Gesture {
        DragGesture()
            .updating( $gesturePan) { value, gesturePan, _ in
                gesturePan = value.translation
            }
            .onEnded { value in
                pan += value.translation
            }
    }
    
    private func emojiDragGesture(in geometry: GeometryProxy) -> some Gesture {
        DragGesture()
            .onChanged { value in
                guard !selection.isEmpty else { return }
                selectionDrag = CGSize(
                    width: value.translation.width / (zoom * gestureZoom),
                    height: value.translation.height / (zoom * gestureZoom)
                )
            }
            .onEnded { value in
                guard !selection.isEmpty else { return }
                let delta = CGSize(
                    width: value.translation.width / (zoom * gestureZoom),
                    height: value.translation.height / (zoom * gestureZoom))
                document.moveEmojis(selection, by: delta, undoWith: undoManager)
                selectionDrag = .zero
            }
    }
    
    private var selectedPinchGesture: some Gesture {
        MagnificationGesture()
            .updating($selectionPinch) { value, state, _ in
                state = value
            }
            .onEnded { scale in
                guard !selection.isEmpty else { return }
                document.resizeEmojis(selection, by: scale, undoWith: undoManager)
            }
    }
    
    private func singleEmojiDrag(_ emoji: Emoji) -> some Gesture {
        DragGesture()
            .onChanged { value in
                guard selection.isEmpty else { return }
                singleDraggingID = emoji.id
                singleDrag = CGSize(
                    width: value.translation.width / (zoom * gestureZoom),
                    height: value.translation.height / (zoom * gestureZoom)
                )
            }
            .onEnded { value in
                guard selection.isEmpty else { return }
                let delta = CGSize(
                    width: value.translation.width / (zoom * gestureZoom),
                    height: value.translation.height / (zoom * gestureZoom)
                )
                document.move(emoji, by: delta, undoWith: undoManager)
                singleDrag = .zero
                singleDraggingID = nil
            }
    }
    
    private func marqueeGesture(in geometry: GeometryProxy) -> some Gesture {
        DragGesture()
            .onChanged { value in
                if marqueeStart == nil {
                    marqueeStart = value.startLocation
                    marqueeRect = .zero
                }
                if let start = marqueeStart {
                    let current = value.location
                    marqueeRect = CGRect(
                        x: min(start.x, current.x),
                        y: min(start.y, current.y),
                        width: abs(start.x - current.x),
                        height: abs(start.y - current.y)
                    )
                }
            }
            .onEnded { value in
                guard let start = marqueeStart else { return }
                let end = value.location
                let rect = CGRect(
                    x: min(start.x, end.x),
                    y: min(start.y, end.y),
                    width: abs(start.x - end.x),
                    height: abs(start.y - end.y)
                )
                for emoji in document.emojis {
                    let pos = emoji.position.in(geometry)
                    if rect.contains(pos) {
                        selection.insert(emoji.id)
                    }
                }
                marqueeStart = nil
                marqueeRect = .zero
            }
    }
    
    @ViewBuilder
    private func selectionHighlight(for emoji: Emoji) -> some View {
        if selection.contains(emoji.id) {
            RoundedRectangle(cornerRadius: 4)
                .stroke(.blue, lineWidth: 2)
        }
    }
    
    @ViewBuilder
    private func documentContents(in geometry: GeometryProxy) -> some View {
        if let uiImage = document.background.uiImage {
            Image(uiImage: uiImage)
                .position(Emoji.Position.zero.in(geometry))
        }
        ForEach(document.emojis) { emoji in
            Text(emoji.string)
                .font(emoji.font)
                .background { selectionHighlight(for: emoji) }
                .contentShape(Rectangle())
                .scaleEffect(selection.contains(emoji.id) ? selectionPinch : 1)
                .position(emoji.position.in(geometry))
                .offset(offsetFor(emoji))
                .onTapGesture {
                    if selection.contains(emoji.id) {
                        selection.remove(emoji.id)
                    } else {
                        selection.insert(emoji.id)
                    }
                }
                .onLongPressGesture {
                    emojiToDelete = emoji.id
                    showDeleteAlert = true
                }
                .highPriorityGesture(selection.isEmpty ? singleEmojiDrag(emoji) : nil)
        }
    }
    
    private func offsetFor(_ emoji: Emoji) -> CGSize {
        if selection.contains(emoji.id) {
            return selectionDrag
        } else if singleDraggingID == emoji.id {
            return singleDrag
        } else {
            return .zero
        }
    }
    
    private func drop(_ sturldatas: [Sturldata], at location: CGPoint, in geometry: GeometryProxy) -> Bool {
        for sturldata in sturldatas {
            switch sturldata {
            case .url(let url):
                document.setBackground(url, undoWith: undoManager)
                return true
            case .string(let emoji):
                document.addEmoji(
                    emoji,
                    at: emojiPosition(at: location, in: geometry),
                    size: paletteEmojiSize / zoom,
                    undoWith: undoManager
                )
                return true
            case .data(let data):
                document.setBackground(data, undoWith: undoManager)
                return true
            }
        }
        return false
    }
    
    private func emojiPosition(at location: CGPoint, in geometry: GeometryProxy) -> Emoji.Position {
        let center = geometry.frame(in: .local).center
        return Emoji.Position(
            x: Int((location.x - center.x - pan.width) / zoom),
            y: Int(-(location.y - center.y - pan.height) / zoom)
        )
    }
}

private extension EmojiArtDocumentView {
    func point(for pos: EmojiArt.Emoji.Position, in size: CGSize) -> CGPoint {
        let c = CGPoint(x: size.width/2, y: size.height/2)
        return CGPoint(x: c.x + CGFloat(pos.x), y: c.y - CGFloat(pos.y))
    }
    
    @ViewBuilder
    func exportCanvas(size: CGSize) -> some View {
        ZStack {
            if let ui = document.background.uiImage {
                Image(uiImage: ui)
                    .position(CGPoint(x: size.width/2, y: size.height/2))
            }
            ForEach(document.emojis) { e in
                Text(e.string)
                    .font(e.font)
                    .position(point(for: e.position, in: size))
            }
        }
        .scaleEffect(zoom * gestureZoom)
        .offset(pan + gesturePan)
        .frame(width: size.width, height: size.height)
    }
    
    func renderPNG(for size: CGSize, scale: CGFloat = 2) -> ExportedPNG? {
        guard size.width > 0, size.height > 0 else { return nil }
        let renderer = ImageRenderer(content: exportCanvas(size: size))
        renderer.scale = scale
        if let ui = renderer.uiImage, let data = ui.pngData() {
            return ExportedPNG(data: data)
        }
        return nil
    }
}

private extension EmojiArtDocumentView {
    enum PhotoSaveError: Error {
        case noImage
        case denied
        case failed(underlying: Error?)
    }
    
    func saveUIImageToPhotos(_ image: UIImage, completion: @escaping (Result<Void, PhotoSaveError>) -> Void) {
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            guard status == .authorized || status == .limited else {
                DispatchQueue.main.async { completion(.failure(.denied)) }
                return
            }
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }) { success, error in
                DispatchQueue.main.async {
                    success ? completion(.success(()))
                            : completion(.failure(.failed(underlying: error)))
                }
            }
        }
    }
}

#Preview {
    EmojiArtDocumentView(document: EmojiArtDocument())
        .environmentObject(PaletteStore(named: "Preview"))
}
