//
//  Emoji_ArtApp.swift
//  Emoji Art
//
//  Created by N L on 18. 7. 2025..
//

import SwiftUI

@main
struct Emoji_ArtApp: App {
    @StateObject var defaultDocument = EmojiArtDocument()
    
    var body: some Scene {
        WindowGroup {
            EmojiArtDocumentView(document: defaultDocument)
        }
    }
}
