//
//  CreateUser.swift
//  lineUpAPI
//
//  Created by Guillaume Richard on 09/10/2026.
//

import Foundation
import Vapor
import Fluent

struct CreateUser: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(User.schema)
            .id()
            .field("name_user", .string, .required)
            .field("email_user", .string, .required)
            .field("passwordHash_user", .string, .required)
            .field("role_user", .string, .required)
            .field("createdAt_user", .datetime, .required)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema(User.schema).delete()
    }
}

