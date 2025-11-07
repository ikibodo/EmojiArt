//
//  ExportedPNG.swift
//  Emoji Art
//
//  Created by N L on 28. 10. 2025..
//

import SwiftUI

struct ExportedPNG: Transferable {
    let data: Data
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .png) { $0.data }
    }
}
