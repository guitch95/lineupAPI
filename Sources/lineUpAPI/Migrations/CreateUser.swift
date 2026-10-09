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
        try await database.schema("users")

    }

    func revert(on database: any Database) async throws {
        try await database.schema("users").delete()
    }
}

