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
    
    // MARK: - Adding Palettes
    
    // Эти функции — рекомендуемый способ добавления палитр в PaletteStore
    // поскольку они позволяют избежать дублирования идентифицируемых идентичных палитр
    // предварительно удаляя/заменяя любую палитру с тем же идентификатором, которая уже есть в Palette
    // это не «устраняет» существующее дублирование, а просто не «вызывает» новое дублирование
    
    func insert(_ palette: Palette, at insertionIndex: Int? = nil) {
        let insertionIndex = bonusCheckedPaletteIndex(insertionIndex ?? cursorIndex)
        if let index = palettes.firstIndex(where: { $0.id == palette.id }) {
            palettes.move(fromOffsets: IndexSet ([index]), toOffset: insertionIndex)
            palettes.replaceSubrange(insertionIndex...insertionIndex, with: [palette])
        } else {
            palettes.insert(palette, at: insertionIndex)
        }
    }
    
    func insert(name: String, emojis: String, at index: Int? = nil) {
        insert(Palette(name: name, emojis: emojis), at: index)
    }
    
    func append(_ palette: Palette) {
        if let index = palettes.firstIndex(where: { $0.id == palette.id }) {
            if palettes.count == 1 {
                palettes = [palette]
            } else {
                palettes.remove(at: index)
                palettes.append (palette)
            }
        } else {
            palettes.append(palette)
        }
    }
    
    func append (name: String, emojis: String) {
        append(Palette(name: name, emojis: emojis))
    }
}
