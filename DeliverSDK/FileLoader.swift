//
//  FileManager.swift
//  DeliverSDK
//
//  Created by Benjamin FROLICHER on 26/12/2023.
//

import Foundation


/// FileLoader ensure that all folder struture are setup folder deliver
internal struct FileLoader {
    
    internal static func load() {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("Deliver", isDirectory: true)
        try! FileManager.default.createDirectory(atPath: url.path, withIntermediateDirectories: true, attributes: nil)
    }
}
