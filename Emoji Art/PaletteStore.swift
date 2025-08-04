//
//  PaletteStore.swift
//  Emoji Art
//
//  Created by N L on 4. 8. 2025..
//

import SwiftUI
// ViewModel_Two
class PaletteStore: ObservableObject {
    let name: String
    @Published var palettes: [Palette] { // специально не заприватил, но ViewModel все равно будет полезна, например в случае если пользователь удалил все палитры и нет ни одной  в моделе (см ниже if d инит)
        didSet {
            if palettes.isEmpty, !oldValue.isEmpty { // !oldValue.isEmpty чтобы не было бесконечного цикла
                palettes = oldValue
            }
        }
    }
    
    init(named name: String) {
        self.name = name
        palettes = Palette.builtins
        if palettes.isEmpty {
            palettes = [Palette(name: "Warning", emojis: "⚠️")]
        }
    }
    
    @Published private var _cursorIndex = 0
    
    var cursorIndex: Int {
        get { bonusCheckedPaletteIndex(_cursorIndex) }
        set { _cursorIndex = bonusCheckedPaletteIndex(newValue)}
    }
    
    private func bonusCheckedPaletteIndex(_ index: Int) -> Int {
        var index = index % palettes.count
        if index < 0 {
            index += palettes.count
        }
        return index
    }
}
