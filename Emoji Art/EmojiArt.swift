//
//  EmojiArt.swift
//  Emoji Art
//
//  Created by N L on 18. 7. 2025..
//

import Foundation
//  Model - будет вкл в себя фон и все эмодзи, их расположение и размер
struct EmojiArt {
    var background: URL? // = nil
    private(set) var emojis = [Emoji]()
    
    private var uniqueEmojiId = 0
    
    mutating func addEmoji(_ emoji: String, at position: Emoji.Position, size: Int) {
        uniqueEmojiId += 1
        emojis.append(Emoji(
            string: emoji,
            position: position,
            size: size,
            id: uniqueEmojiId
        ))
    }
    
    struct Emoji: Identifiable {
        let string: String
        var position: Position
        var size: Int
        var id: Int
        
        struct Position {
            var x: Int
            var y: Int
            
            static let zero = Self(x: 0, y: 0)
        }
    }
}
