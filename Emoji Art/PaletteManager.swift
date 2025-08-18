//
//  PaletteManager.swift
//  Emoji Art
//
//  Created by N L on 15. 8. 2025..
//

import SwiftUI
// управляет всеми палитрами во всех сторах
struct PaletteManager: View {
    let stores: [PaletteStore]
    
    @State private var selectedStore: PaletteStore?
    
    var body: some View {
        NavigationSplitView {
            List(stores, selection: $selectedStore) { store in
                Text(store.name)
                    .tag(store)
            }
        }content: {
            if let selectedStore  {
                EditablePaletteList(store: selectedStore)
            }
            Text("Choose a store")
        } detail : {
            Text("Choose a palette")
        }
    }
}

//#Preview {
//    PaletteManager()
//}
