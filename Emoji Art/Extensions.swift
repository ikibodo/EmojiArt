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

extension String {
    var uniqued: String {
        reduce(into: "") { sofar, element in
            if !sofar.contains(element) {
                sofar.append(element)
            }
        }
    }
}

extension URL { //  не по лекции, фиксила dataSchemeImageData - утончить в примере 
    var dataSchemeImageData: Data? {
        guard scheme == "data",
              let dataRange = absoluteString.range(of: "base64,") else {
            return nil
        }

        let base64String = String(absoluteString[dataRange.upperBound...])
        return Data(base64Encoded: base64String)
    }
}
