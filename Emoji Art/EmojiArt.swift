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
    var emojis = [Emoji]()
    
    struct Emoji {
        let string: String // единственное что не даем менять - сами эмодзи 
        var position: Position
        var size: Int
        
        struct Position {
            var x: Int
            var y: Int
        }
    }
}
