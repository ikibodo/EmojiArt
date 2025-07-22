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
    
    func addEmoji(_ emoji: String, at position: Emoji.Position, size: CGFloat) {
        emojiArt.addEmoji(emoji, at: position, size: Int(size))
    }
}

extension EmojiArt.Emoji { // вынесли из View во  View Model потому что это его работа помогать View и упрощать жизнь
    var font: Font {
        Font.system(size: CGFloat(size))
    }
}

extension EmojiArt.Emoji.Position {
    func `in`(_ geometry: GeometryProxy) -> CGPoint { // `in` - одинарные обратные кавычки способ использовать зарезервированное ключевое слово в качестве имени то одинарные обратные кавычки как бы экранирование его
        let center = geometry.frame(in: .local).center
        return CGPoint(x: center.x + CGFloat(x), y: center.y - CGFloat(y)) // минус потому что система у вппле перевернута, а мы хотим использовать в этом приложении декартову вертикальную  
    }
}
