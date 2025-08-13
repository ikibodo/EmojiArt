//
//  PaletteEditor.swift
//  Emoji Art
//
//  Created by N L on 13. 8. 2025..
//

import SwiftUI

struct PaletteEditor: View {
    let palette: Palette
    
    private let emojiFont = Font.system(size: 40)
    
    var body: some View {
//        VStack(alignment: .leading) {
        Form { // удобен когда нужно собрать информацию от пользователя и часто используется в настройках
            Section(header: Text("Name")) {
                Text(palette.name)
            }
            Section(header: Text("Emojis")) {
                Text("Add Emojis Here")
                    .font(emojiFont)
                removeEmojis
            }
        }
            .frame(minWidth: 300, minHeight: 350)
    }
    
    var removeEmojis: some View {
        VStack(alignment: .trailing) {
            Text("Tap to Remove Emojis").font(.caption).foregroundColor(.gray)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 40))]) {
                ForEach(palette.emojis.uniqued.map(String.init), id: \.self) { emoji in
                    Text(emoji)
                }
            }
        }
        .font(emojiFont)
    }
}

//#Preview {
//    PaletteEditor()
//}
