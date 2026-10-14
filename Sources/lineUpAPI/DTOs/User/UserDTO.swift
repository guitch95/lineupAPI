//
//  File.swift
//  lineUpAPI
//
//  Created by Canessane Ramya on 13/10/2026.
//

import Fluent
import Vapor

// Réponse retournée à l'api par l'utilisateur
struct UserDTO: Content {
    var id: UUID?
    var name: String
    var email: String
    var role: UserRole 
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
