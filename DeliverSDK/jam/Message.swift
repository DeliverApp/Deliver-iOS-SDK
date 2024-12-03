//
//  Message.swift
//  atlantis
//
//  Created by Nghia Tran on 10/25/20.
//  Copyright © 2020 Proxyman. All rights reserved.
//

import Foundation

struct Message: Codable {

    enum MessageType: String, Codable {
        case traffic // Request/Response log
        case websocket // for websocket send/receive/close
    }

    // MARK: - Variables

    internal let id: String
    internal let messageType: MessageType
    internal let content: TrafficPackage?

    // MARK: - Init

    private init(id: String, messageType: Message.MessageType, content: TrafficPackage?) {
        self.id = id
        self.messageType = messageType
        self.content = content
    }

    // MARK: - Helper Builder

//    static func buildConnectionMessage(id: String, item: Serializable) -> Message {
//        return Message(id: id, messageType: MessageType.connection, content: item.toData())
//    }

    static func buildTrafficMessage(id: String, item: TrafficPackage) -> Message {
        return Message(id: id, messageType: MessageType.traffic, content: item)
    }

    static func buildWebSocketMessage(id: String, item: TrafficPackage) -> Message {
        return Message(id: id, messageType: MessageType.websocket, content: item)
    }
}

// MARK: - Serializable

extension Message: Serializable {

    func toData() -> Data? {
        do {
            return try JSONEncoder().encode(self)
        } catch let error {
            print("[DeliverJam][Error] Can't serialize request with error \(error)")
        }
        return nil
    }
}
