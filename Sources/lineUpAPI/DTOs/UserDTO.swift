//
//  File.swift
//  lineUpAPI
//
//  Created by Canessane Ramya on 12/10/2026.
//

import Vapor
import Fluent

// Réponse retournée par l'API à l'utilisateur
struct UserDTO: Content {
    var id: UUID?
    var name: String
    var email: String
    var role: String
    var createdAt: Date?
}

extension User {
    func toDTO() throws -> UserDTO {
        return UserDTO(
            id: try requireID(),
            name: name,
            email: email,
            role: role,
            createdAt: createdAt
        )
    }
}
