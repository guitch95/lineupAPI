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
    var role: String
    var createdAt: Date?
}

struct CreateUserDTO: Content {
    var name: String
    var email: String
    var passwordHash: String
    var role: String
    
    func toModel() -> User {
        User(
            name: name,
            email: email,
            passwordHash: passwordHash,
            role: role
        )
    }
}

struct UpdateUserDTO: Content {
    var name: String?
    var email: String?
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
