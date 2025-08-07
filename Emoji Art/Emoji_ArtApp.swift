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
    @StateObject var paletteStore = PaletteStore(named: "Main")
    
    var body: some Scene {
        WindowGroup {
            EmojiArtDocumentView(document: defaultDocument)
                .environmentObject(paletteStore) // используется глобально
        }
    }
}
