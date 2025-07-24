//
//  Sturldata.swift
//  Emoji Art
//
//  Created by N L on 25. 7. 2025..
//

import CoreTransferable

enum Sturldata: Transferable {
    
    case string(String)
    case url(URL)
    case data(Data)
    
    init(url: URL) {
        if let imageData = url.dataSchemeImageData {
            self = .data(imageData)
        } else {
            self = .url(url)
        }
    }
    
    init(string: String) {
        if string.hasPrefix("http"), let url = URL(string: string) {
            self = .url(url)
        } else {
            self = .string(string)
        }
    }
    
    static var transferRepresentation: some TransferRepresentation {
        ProxyRepresentation { Sturldata(string: $0) }
        ProxyRepresentation { Sturldata(url: $0) }
        ProxyRepresentation { Sturldata.data($0) }
    }
}

extension URL {
    var imageURL: URL {
        if let queryItems = URLComponents(url: self, resolvingAgainstBaseURL: true)?.queryItems {
            for queryItem in queryItems {
                if let value = queryItem.value, value.hasPrefix("http"), let imgurl = URL(string: value) {
                    return imgurl
                }
            }
        }
        return self
    }
    
    var dataSchemeImageData: Data? {
        let urlString = absoluteString
        if urlString.hasPrefix("data:image") {
            if let comma = urlString.firstIndex(of: ","), comma < urlString.endIndex {
                let meta = urlString[..<comma]
                if meta.hasSuffix("base64") {
                    let data = String(urlString.suffix(after: comma))
                    if let imageData = Data(base64Encoded: data) {
                        return imageData
                    }
                }
            }
        }
        return nil
    }
}

extension Collection {
    func suffix(after: Self.Index) -> Self.SubSequence {
        suffix(from: index(after: after))
    }
}
