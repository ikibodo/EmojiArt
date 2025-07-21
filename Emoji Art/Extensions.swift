//
//  Extensions.swift
//  Emoji Art
//
//  Created by N L on 21. 7. 2025..
//

import SwiftUI

//typealias CGOffset = CGSize

//extension CGPoint {
//    var center: CGPoint {
//        CGPoint(x: midX, y: midY)
//    }
//    init(center: CGPoint, size: CGSize) {
//        self.init(origin: CGPoint(x: center.x-size.width/2, y: center.y-size.height/2),  size: size)
//    }
//}

extension String {
    var uniqued: String {
        reduce(into: "") { sofar, element in
            if !sofar.contains(element) {
                sofar.append(element)
            }
        }
    }
}
