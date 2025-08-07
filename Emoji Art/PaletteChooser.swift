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
    }
    
    var chooser: some View {
        Button {
            
        } label: {
            Image(systemName: "paintpalette")
        }
    }
    
    func view(for palette: Palette) -> some View {
        HStack {
            Text(palette.name)
            ScrollingEmojis(palette.emojis)
        }
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
