//
//  PaletteChooser.swift
//  Emoji Art
//
//  Created by N L on 7. 8. 2025..
//

import SwiftUI

struct PaletteChooser: View {
    @EnvironmentObject var store: PaletteStore // получи что-то типа PaletteStore что было внедрено в меня (и это что-то только одно)
    
    var body: some View {
        HStack {
            chooser
            view(for: store.palettes[store.cursorIndex])
        }
        .clipped() // останется внутри своих границ
    }
    
    var chooser: some View {
        AnimatedActionButton(systemImage: "paintpalette") {
            store.cursorIndex += 1
        }
        .contextMenu{
            AnimatedActionButton("New", systemImage: "plus") {
                store.insert(name: "Math", emojis: "➕➖✖️🟰")
            }
            AnimatedActionButton("Delete", systemImage: "minus.circle", role: .destructive) { // destructive делает красным лейбл на кнопке
                store.palettes.remove(at: store.cursorIndex)
            }
        }
    }
    
    func view(for palette: Palette) -> some View {
        HStack {
            Text(palette.name)
            ScrollingEmojis(palette.emojis)
        }
        .id(palette.name) // способ заставить представления появляться и исчезать, присваивая им идентификаторы
        .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .top))) // работает благодаря id выше
    }
}

struct ScrollingEmojis: View {
    let emojis: [String]
    init(_ emojis: String) {
        self.emojis = emojis.uniqued.map(String.init)
    }
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(emojis, id: \.self) { emoji in
                    Text(emoji)
                        .draggable(emoji)
                }
            }
        }
    }
}

#Preview {
    PaletteChooser()
        .environmentObject(PaletteStore(named: "Preview"))
}
