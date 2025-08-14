//
//  PaletteList.swift
//  Emoji Art
//
//  Created by N L on 14. 8. 2025..
//

import SwiftUI

struct PaletteList: View {
    @EnvironmentObject var store: PaletteStore
    
    var body: some View {
        NavigationStack { // контейнер для навигации всего что внутри него
            List(store.palettes) { palette in // VStack -> List  ( как и Form часто используется) имеет свой встроенный ForEach
                NavigationLink(value: palette) { // что будет нажиматься и с чем ассоциировано
                    Text(palette.name)
                }
            }
            .navigationDestination(for: Palette.self) { palette in
                PaletteView(palette: palette)
            }
        }
    }
}

struct PaletteView: View {
    let palette: Palette
    
    var body: some View {
        VStack {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 40))]) {
                ForEach(palette.emojis.uniqued.map(String.init), id: \.self) { emoji in
                    NavigationLink(value: emoji) {
                        Text(emoji)
                    }
                }
            }
            Spacer()
        }
        .padding()
        .font(.largeTitle)
    }
}

#Preview {
    PaletteList()
}
