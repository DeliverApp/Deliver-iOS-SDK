//
//  Collection+Safe.swift
//  DeliverSDK
//
//  Created by Benjamin FROLICHER on 25/12/2023.
//

import Foundation

extension Collection {
    
    subscript(safe i: Index) -> Element? {
        get {
            guard self.indices.contains(i) else { return nil }
            return self[i]
        }
    }
}
