//
//  EmojiArtDocument.swift
//  Emoji Art
//
//  Created by N L on 18. 7. 2025..
//

import SwiftUI
// View Model
class EmojiArtDocument: ObservableObject {
    typealias Emoji = EmojiArt.Emoji
    
    private var emojiArt = EmojiArt() // так как EmojiArt.background = nil нам не надо ничего инитить
    
    var emojis: [Emoji] {
        emojiArt.emojis
    }
    
    var background: URL? {
        emojiArt.background
    }
    
    // MARK: - Intent(s)
    
    func setBackground(_ url: URL?) {
        emojiArt.background = url
    }
}
