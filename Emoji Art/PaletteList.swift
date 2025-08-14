//
//  PaletteList.swift
//  Emoji Art
//
//  Created by N L on 14. 8. 2025..
//

import SwiftUI

struct PaletteList: View {
    @EnvironmentObject var store: PaletteStore
    
    var body: some View {
        VStack {
            ForEach(store.palettes) { palette in
                Text(palette.name)
            }
        }
    }
}

#Preview {
    PaletteList()
}
