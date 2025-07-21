//
//  EmojiArtDocumentView.swift
//  Emoji Art
//
//  Created by N L on 21. 7. 2025..
//

import SwiftUI
// View
struct EmojiArtDocumentView: View {
    
    private let emojis = "👻🍎😃🤪☹️🤯🐶🐭🦁🐵🦆🐝🐢🐄🐖🌲🌴🌵🍄🌝🌍🌈🔥🌧️🌨️⛳🛥🚗🚙🚲🚲🏍🛺🛵✈️🚀🚁🏡🤺🏰❤️💤🐎"
    
    var body: some View {
        VStack {
            Color.yellow
            ScrollingEmojis()
        }
    }
}

struct ScrollingEmojis: View {
    let emojis: [String] // потому что Text принимает  String
    
    init(emojis: [String]) {
        self.emojis = emojis
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
    EmojiArtDocumentView()
}
