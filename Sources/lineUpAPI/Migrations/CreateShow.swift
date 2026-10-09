//
//  CreateShow.swift
//  lineUpAPI
//
//  Created by Guillaume Richard on 09/10/2026.
//

import Foundation
import Vapor
import Fluent

struct CreateShow: AsyncMigration {

    func prepare(on database: any Database) async throws {
        try await database.schema("shows")

    }

    func revert(on database: any Database) async throws {
        try await database.schema("shows").delete()
    }
}

