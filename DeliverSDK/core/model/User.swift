//
//  User.swift
//  Deliver-Store
//
//  Created by Benjamin FROLICHER on 24/11/2024.
//

internal struct User: Codable {
    var id: String = ""
    var firstname: String?
    var lastname: String?
    var email: String
    var username: String?
    var avatar: String?
    
    var fullName: String {
        return "\(firstname ?? "") \(lastname ?? "")"
    }
    
    var initial: String {
        return "\(firstname?.prefix(1) ?? "")\(lastname?.prefix(1) ?? "")"
    }
    
}
