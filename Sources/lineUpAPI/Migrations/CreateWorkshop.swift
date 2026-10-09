//
//  File.swift
//  lineUpAPI
//
//  Created by Guillaume Richard on 09/10/2026.
//

import Fluent
struct CreateWorkshop: AsyncMigration {

    func prepare(on database: any Database) async throws {
        try await database.schema("workshops")

    }

    func revert(on database: any Database) async throws {
        try await database.schema("workshops").delete()
    }
}

