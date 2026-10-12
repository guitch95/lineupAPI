//
//  File.swift
//  lineUpAPI
//
//  Created by Canessane Ramya on 12/10/2026.
//

import Foundation
import Vapor

struct CreateUserDTO: Content {
    var name: String
    var email: String
    var passwordHash: String
    var role: String
    
    func toModel() -> User {
        let user = User(
            name: name,
            email: email,
            passwordHash: passwordHash,
            role: role
        )
        return user
    }
}
