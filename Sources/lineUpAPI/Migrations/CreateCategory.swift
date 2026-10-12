//
//  CreateCategory.swift
//  lineUpAPI
//
//  Created by Guillaume Richard on 12/10/2026.
//

import Fluent
struct CreateCategory: AsyncMigration {

    func prepare(on database: any Database) async throws {
        try await database.schema("categories")

    }

    func revert(on database: any Database) async throws {
        try await database.schema("categories").delete()
    }
}

