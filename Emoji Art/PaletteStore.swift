//
//  PaletteStore.swift
//  Emoji Art
//
//  Created by N L on 4. 8. 2025..
//

import SwiftUI

// ViewModel_Two

extension PaletteStore: Hashable {
    static func == (lhs: PaletteStore, rhs: PaletteStore) -> Bool {
        lhs.name == rhs.name
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}

class PaletteStore: ObservableObject, Identifiable {
    let name: String
    
    var id: String { name }
    
    private var userDefaultsKey: String { "PaletteStore:" + name }
    private var observer: NSObjectProtocol?
    
    var palettes: [Palette] {
        get {
            UserDefaults.standard.palettes(forKey: userDefaultsKey)
        }
        set {
//            if !newValue.isEmpty {
//                UserDefaults.standard.set(newValue, forKey: userDefaultsKey)
//                objectWillChange.send()
//            }
            guard !newValue.isEmpty else { return }
            UserDefaults.standard.set(newValue, forKey: userDefaultsKey)
            DispatchQueue.main.async { [weak self] in
                self?.objectWillChange.send()
            }
        }
    }
    
    init(named name: String) {
        self.name = name
        if palettes.isEmpty {
            palettes = Palette.builtins
            if palettes.isEmpty {
//                palettes = [Palette(name: "Warning", emojis: "⚠️")]
                palettes = Palette.builtins.isEmpty
                    ? [Palette(name: "Warning", emojis: "⚠️")]
                    : Palette.builtins
            }
        }
        observer = NotificationCenter.default.addObserver(
            forName: UserDefaults.didChangeNotification,
            object: nil,
            queue: .main ) { [weak self] _ in // self тут это просто список вещей, которые нужно зафиксировать, чтобы замыкание сработало, а  weak self означает что не стоит хранить это в куче, и если никто этим не пользуется, то просто сделай это nil и self становится опциональным и больше не хранит это в куче
//                self.objectWillChange.send() // говорит - "иди и обнови вью потому что я каким-то образом изменился". Это замыкание, захватившее self (содержащее внутри указатель на PaletteStore),  остается в куче и центр уведомления удерживает его ожидая уведомления чтобы можно было вызвать это замыкание. Но это может длиться вечно
                DispatchQueue.main.async { [weak self] in
                    self?.objectWillChange.send() //Версия по лекции без DispatchQueue.main.async дает фиолетовую ошибку: Publishing changes from within view updates is not allowed, this will cause undefined behavior.
                }
            }
    }
    
    deinit { // работает только с ссылочными типами, вызывается когда вы покидаете кучу, и если на вас больше никто не указывает, вас выбрасывают из кучи.
        print("remove observer")
//        if let observer {
//            NotificationCenter.default.removeObserver(observer)
//        }
        if let obs = observer {
            NotificationCenter.default.removeObserver(obs)
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
