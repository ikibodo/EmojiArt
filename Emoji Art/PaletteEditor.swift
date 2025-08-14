//
//  PaletteEditor.swift
//  Emoji Art
//
//  Created by N L on 13. 8. 2025..
//

import SwiftUI

struct PaletteEditor: View {
    @Binding var palette: Palette // будем ссылаться на палитру обратно во ViewModel
    
    private let emojiFont = Font.system(size: 40)
    
    @State private var emojisToAdd: String = ""
    
    enum Focused {
        case name
        case addEmojis
    }
    
    @FocusState private var focused: Focused?
    
    var body: some View {
        Form { // удобен когда нужно собрать информацию от пользователя и часто используется в настройках
            Section(header: Text("Name")) {
                TextField("Name", text: $palette.name) //$ привязка к привязке Binding
                    .focused($focused, equals: .name)
            }
            Section(header: Text("Emojis")) {
                TextField("Add Emojis Here", text: $emojisToAdd)
                    .focused($focused, equals: .addEmojis)
                    .font(emojiFont)
                    .onChange(of: emojisToAdd) { emojisToAdd in
                        palette.emojis = (emojisToAdd + palette.emojis)
                            .filter { $0.isEmoji } // нет в swift, см расширения
                            .uniqued
                    }
                removeEmojis
            }
        }
            .frame(minWidth: 300, minHeight: 350)
            .onAppear {
                if palette.name.isEmpty {
                    focused = .name
                } else {
                    focused = .addEmojis
                }
            }
    }
    
    var removeEmojis: some View {
        VStack(alignment: .trailing) {
            Text("Tap to Remove Emojis").font(.caption).foregroundColor(.gray)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 40))]) {
                ForEach(palette.emojis.uniqued.map(String.init), id: \.self) { emoji in
                    Text(emoji)
                        .onTapGesture {
                            withAnimation {
                                palette.emojis.remove(emoji.first!)
                                emojisToAdd.remove(emoji.first!)
                            }
                        }
                }
            }
        }
        .font(emojiFont)
    }
}

//#Preview {
//    PaletteEditor()
//}
