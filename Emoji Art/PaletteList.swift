//
//  PaletteList.swift
//  Emoji Art
//
//  Created by N L on 14. 8. 2025..
//

import SwiftUI

struct EditablePaletteList: View {
    @EnvironmentObject var store: PaletteStore
    
    @State private var showCursorPalette = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(store.palettes) { palette in
                    NavigationLink(value: palette) {
                        VStack(alignment: .leading) {
                            Text(palette.name)
                            Text(palette.emojis).lineLimit(1)
                        }
                    }
                }
                .onDelete { indexSet in // работает в ForEach
                    withAnimation {
                        store.palettes.remove(atOffsets: indexSet)
                    }
                }
                .onMove { indexSet, newOffset in
                    store.palettes.move(fromOffsets: indexSet, toOffset: newOffset)
                }
            }
            .navigationDestination(for: Palette.self) { palette in
                if let index = store.palettes.firstIndex(where: { $0.id == palette.id }) {
                    PaletteEditor(palette: $store.palettes[index])
                }
            }
            .navigationDestination(isPresented: $showCursorPalette) {
                PaletteEditor(palette: $store.palettes[store.cursorIndex])
            }
            .navigationTitle("\(store.name) Palettes")
            .toolbar {
                Button {
                    store.insert(name: "", emojis: "")
                    showCursorPalette = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }
}

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
            .navigationTitle("\(store.name) Palettes") // должен быть внтури NavigationStack но вне List но рядом с navigationDestination
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
            .navigationDestination(for: String.self) { emoji in
                Text(emoji).font(.system(size: 300))
            }
            Spacer()
        }
        .padding()
        .font(.largeTitle)
        .navigationTitle(palette.name) // имя title прикрепляем  к отображаемым представлениям и он будет показываться наверху
    }
}

#Preview {
    PaletteList()
}
