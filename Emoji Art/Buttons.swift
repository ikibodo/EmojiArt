//
//  Buttons.swift
//  Emoji Art
//
//  Created by N L on 22. 9. 2025..
//

import SwiftUI

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

