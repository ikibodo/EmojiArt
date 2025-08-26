//
//  Emoji_ArtApp.swift
//  Emoji Art
//
//  Created by N L on 18. 7. 2025..
//

import SwiftUI

@main
struct Emoji_ArtApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: { EmojiArtDocument() }) { config in
            EmojiArtDocumentView(document: config.document)
        }
    }
}
