//
//  User.swift
//  lineUpAPI
//
//  Created by Guillaume Richard on 09/10/2026.
//

import Foundation
import Vapor
import Fluent

final class User: Model, Content, @unchecked Sendable {
    static let schema = "users"

    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name_user")
    var name: String
    
    @Field(key: "email_user")
    var email: String
    
    @Field(key: "passwordHash_user")
    var passwordHash: String
    
    @Field(key: "role_user")
    var role: UserRole
    
    @Timestamp(key: "createdAt_user", on: .create)
    var createdAt: Date?
    
    @Children(for: \.$user)
    var reservations: [Reservation]

    init() {}

    init(id: UUID? = nil, name: String, email: String, passwordHash: String, role: UserRole = .festivalier) {
        self.id = id
        self.name = name
        self.email = email
        self.passwordHash = passwordHash
        self.role = role
    }
}

