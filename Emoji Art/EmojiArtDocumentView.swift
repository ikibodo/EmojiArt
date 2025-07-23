//
//  EmojiArtDocumentView.swift
//  Emoji Art
//
//  Created by N L on 21. 7. 2025..
//

import SwiftUI
// View
struct EmojiArtDocumentView: View {
    typealias Emoji = EmojiArt.Emoji
    
    @ObservedObject var document: EmojiArtDocument
    
    private let emojis = "👻🍎😃🤪☹️🤯🐶🐭🦁🐵🦆🐝🐢🐄🐖🌲🌴🌵🍄🌝🌍🌈🔥🌧️🌨️⛳🛥🚗🚙🚲🚲🏍🛺🛵✈️🚀🚁🏡🤺🏰❤️💤🐎"
    
    private let paletteEmojiSize: CGFloat = 40
    
    var body: some View {
        VStack(spacing: 0) {
            documentBody
            ScrollingEmojis(emojis)
                .font(.system(size: paletteEmojiSize))
                .padding(.horizontal)
                .scrollIndicators(.hidden)
        }
    }
    
    private var documentBody: some View {
        GeometryReader { geometry in // считывает систему координат
            ZStack {
                Color.white
                AsyncImage(url: document.background)
//                    .position(Emoji.Position(x: 0, y: 0).in(geometry))
                    .position(Emoji.Position.zero.in(geometry))
                ForEach(document.emojis) { emoji in
                    Text(emoji.string)
                        .font(emoji.font)
                        .position(emoji.position.in(geometry))
                }
            }
        }
    }
}


struct ScrollingEmojis: View {
    let emojis: [String] // потому что Text принимает  String
    
    init(_ emojis: String) {
//        self.emojis = emojis.uniqued.map { String($0) }
        self.emojis = emojis.uniqued.map(String.init) // .init конструирующая функция передаю функцию которая принимает Character (или другое) и возвращает String
    }
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(emojis, id: \.self) { emoji in
                    Text(emoji)
                }
            }
        }
    }
}

#Preview {
    EmojiArtDocumentView(document: EmojiArtDocument())
}
