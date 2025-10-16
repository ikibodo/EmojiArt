//
//  Extensions.swift
//  Emoji Art
//
//  Created by N L on 21. 7. 2025..
//

import SwiftUI

typealias CGOffset = CGSize

extension CGRect {
    var center: CGPoint {
        CGPoint(x: midX, y: midY)
    }
    init(center: CGPoint, size: CGSize) {
        self.init(origin: CGPoint(x: center.x-size.width/2, y: center.y-size.height/2), size: size)
    }
}

extension CGOffset {
    static func +(lhs: CGOffset, rhs: CGOffset) -> CGOffset {
        CGOffset(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }
    static func +=(lhs: inout CGOffset, rhs: CGOffset) {
        lhs = lhs + rhs
    }
}

extension UserDefaults {
    func palettes(forKey key: String) -> [Palette] {
        if let jsonData = data(forKey: key),
           let decodedPalettes = try? JSONDecoder().decode([Palette].self, from: jsonData) {
            return decodedPalettes
        } else {
            return []
        }
    }
    
    func set(_ palettes: [Palette], forKey key: String) {
        let data = try? JSONEncoder().encode(palettes)
        set(data, forKey: key)
    }
}

extension String {
    var uniqued: String {
        reduce(into: "") { sofar, element in
            if !sofar.contains(element) {
                sofar.append(element)
            }
        }
    }
}

extension AnyTransition {
    static let rollUp: AnyTransition = asymmetric(insertion: .move(edge: .bottom), removal: .move (edge: .top))
    static let rollDown: AnyTransition = .asymmetric(insertion: .move(edge: .top), removal: .move(edge: .bottom) )
}

extension Character {
    var isEmoji: Bool {
        if let firstScalar = unicodeScalars.first, firstScalar.properties.isEmoji {
            return (firstScalar.value >= 0x238d) || unicodeScalars.count > 1
        } else {
            return false
        }
    }
}

extension String {
    mutating func remove(_ ch: Character) {
        removeAll(where: { $0 == ch })
    }
}

extension URL {
    static func imageDataURL(from data: Data) -> URL? {
        let bytes = [UInt8](data.prefix(8))
        let isPNG  = bytes.starts(with: [0x89, 0x50, 0x4E, 0x47])
        let isJPEG = bytes.prefix(2) == [0xFF, 0xD8]

        if isPNG || isJPEG {
            let mime = isPNG ? "image/png" : "image/jpeg"
            return URL(string: "data:\(mime);base64,\(data.base64EncodedString())")
        } else if let ui = UIImage(data: data), let png = ui.pngData() {
            return URL(string: "data:image/png;base64,\(png.base64EncodedString())")
        } else {
            return nil
        }
    }
}
