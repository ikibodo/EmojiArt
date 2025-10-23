//
//  Buttons.swift
//  Emoji Art
//
//  Created by N L on 22. 9. 2025..
//

import SwiftUI
import PhotosUI

struct AnimatedActionButton: View {
    var title: String? = nil
    var systemImage: String? = nil
    var role: ButtonRole?
    let action: () -> Void
    
    init(_ title: String? = nil, systemImage: String? = nil, role: ButtonRole? = nil, action: @escaping () -> Void) {
        self.title = title
        self.systemImage = systemImage
        self.role = role
        self.action = action
    }
    
    var body: some View {
        Button (role: role) {
            withAnimation {
                action ()
            }
        } label: {
            if let title, let systemImage {
                Label(title, systemImage: systemImage)
            } else if let title {
                Text (title)
            } else if let systemImage {
                Image (systemName: systemImage)
            }
        }
    }
}

struct UndoButton: View {
    @Environment(\.undoManager) var undoManager
    
    @State private var showUndoMenu = false
    
    var body: some View {
        if let undoManager {
            Image(systemName: "arrow.uturn.backward.circle")
                .foregroundColor(.accentColor)
                .onTapGesture {
                    undoManager.undo()
                }
                .onLongPressGesture(minimumDuration: 0.05) {
                    showUndoMenu = true
                }
                .popover(isPresented: $showUndoMenu) {
                    VStack {
                        if !undoManager.canUndo, !undoManager.canRedo {
                            Text("Nothing to Undo")
                        } else {
                            if undoManager.canUndo {
                                Button("Undo " + undoManager.undoActionName) {
                                    undoManager.undo()
                                    showUndoMenu = false
                                }
                            }
                            if undoManager.canRedo {
                                if undoManager.canUndo {
                                    Divider()
                                }
                                Button("Redo " + undoManager.redoActionName) {
                                    undoManager.redo()
                                    showUndoMenu = false
                                }
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: 280)
                }
        }
    }
}

struct DeleteButton: View {
    @Environment(\.undoManager) private var undoManager
    let document: EmojiArtDocument
    @Binding var selection: Set<EmojiArt.Emoji.ID>
    
    var body: some View {
        Button(role: .destructive) {
            document.removeEmojis(selection, undoWith: undoManager)
            selection.removeAll()
        } label: {
            Label("Delete", systemImage: "trash")
        }
        .disabled(selection.isEmpty)
        .keyboardShortcut(.delete, modifiers: [])
        .help("Delete selected emojis")
    }
}

struct ChooseBackgroundButton: View {
    @Environment(\.undoManager) private var undoManager
    let document: EmojiArtDocument

    @State private var pickerItem: PhotosPickerItem?
    @State private var showNoImageAlert = false

    var body: some View {
        PhotosPicker(
            selection: $pickerItem,
            matching: .images,
            photoLibrary: .shared()
        ) {
            Label("Choose Background", systemImage: "photo")
        }
        .labelStyle(.iconOnly)
        .buttonStyle(.borderless)
        .onChange(of: pickerItem) { _, newItem in
            guard let item = newItem else { return }
            Task {
                defer { pickerItem = nil }
                if let data = try? await item.loadTransferable(type: Data.self) {
                    document.setBackground(data, undoWith: undoManager)
                    return
                }
                if let url = try? await item.loadTransferable(type: URL.self) {
                    document.setBackground(url, undoWith: undoManager)
                    return
                }
                showNoImageAlert = true
            }
        }
        .alert("Нечего выбрать", isPresented: $showNoImageAlert) {
            Button("ОК", role: .cancel) {}
        } message: {
            Text("Не удалось получить изображение из Фото.")
        }
    }
}

struct PasteBackgroundButton: View {
    @Environment(\.undoManager) private var undoManager
    let document: EmojiArtDocument
    
    @State private var showNoImageAlert = false
    
    var body: some View {
        PasteButton(payloadType: Sturldata.self) { items in
            if !handlePaste(items) {
                showNoImageAlert = true
            }
        }
        .labelStyle(.iconOnly)
        .buttonStyle(.borderless)
        .help("Paste image or image URL as background")
        .alert("Nothing to paste", isPresented: $showNoImageAlert) {
            Button("OK", role: .cancel) {}
        }
    }
    
    private func handlePaste(_ items: [Sturldata]) -> Bool {
        for item in items {
            switch item {
            case .url(let url):
                document.setBackground(url, undoWith: undoManager)
                return true
            case .data(let data):
                document.setBackground(data, undoWith: undoManager)
                return true
            case .string(let s):
                if let url = URL(string: s)?.imageURL {
                    document.setBackground(url, undoWith: undoManager)
                    return true
                }
            }
        }
        return false
    }
}

struct BringToFrontButton: View {
    @Environment(\.undoManager) private var undoManager
    let document: EmojiArtDocument
    @Binding var selection: Set<EmojiArt.Emoji.ID>

    var body: some View {
        Button {
            document.bringToFront(selection, undoWith: undoManager)
        } label: {
            Label("Bring to Front", systemImage: "square.3.stack.3d.top.filled")
        }
        .disabled(selection.isEmpty)
        .help("Bring selected to front")
    }
}

struct SendToBackButton: View {
    @Environment(\.undoManager) private var undoManager
    let document: EmojiArtDocument
    @Binding var selection: Set<EmojiArt.Emoji.ID>

    var body: some View {
        Button {
            document.sendToBack(selection, undoWith: undoManager)
        } label: {
            Label("Send to Back", systemImage: "square.3.stack.3d.bottom.filled")
        }
        .disabled(selection.isEmpty)
        .help("Send selected to back")
    }
}
