//
//  EmojiArt.swift
//  Emoji Art
//
//  Created by N L on 18. 7. 2025..
//

import Foundation
//  Model
struct EmojiArt: Codable {
    var background: URL?
    private(set) var emojis = [Emoji]()
    
    func json() throws -> Data {
        let encoder = try JSONEncoder().encode(self)
        print("EmojiArt = \(String(data: encoder, encoding: .utf8) ?? "nil")")
        return encoder
    }
    
    init(json: Data) throws {
        self = try JSONDecoder().decode(EmojiArt.self, from: json)
    }
    
    init() {
    }
    
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
    
    mutating func remove(emojiWithId id: Emoji.ID) {
        if let i = index(of: id) {
            emojis.remove(at: i)
        }
    }
    
    mutating func removeEmojis(withIDs ids: Set<Emoji.ID>) {
        emojis.removeAll { ids.contains($0.id) }
    }
    
    mutating func bringToFront(_ ids: Set<Emoji.ID>) {
        let selected = emojis.filter { ids.contains($0.id) }
        let others   = emojis.filter { !ids.contains($0.id) }
        emojis = others + selected
    }

    mutating func sendToBack(_ ids: Set<Emoji.ID>) {
        let selected = emojis.filter { ids.contains($0.id) }
        let others   = emojis.filter { !ids.contains($0.id) }
        emojis = selected + others
    }
    
    subscript(_ emojiId: Emoji.ID) -> Emoji? {
        if let index = index(of: emojiId) {
            return emojis[index]
        } else {
            return nil
        }
    }

    subscript(_ emoji: Emoji) -> Emoji {
        get {
            if let index = index(of: emoji.id) {
                return emojis[index]
            } else {
                return emoji // should probably throw error
            }
        }
        set {
            if let index = index(of: emoji.id) {
                emojis[index] = newValue
            }
        }
    }
    
    private func index(of emojiId: Emoji.ID) -> Int? {
        emojis.firstIndex(where: { $0.id == emojiId })
    }
    
    struct Emoji: Identifiable, Codable {
        let string: String
        var position: Position
        var size: Int
        var id: Int
        
        struct Position: Codable {
            var x: Int
            var y: Int
            
            static let zero = Self(x: 0, y: 0)
        }
    }
}
