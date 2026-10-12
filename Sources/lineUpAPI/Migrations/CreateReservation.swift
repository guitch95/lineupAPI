//
//  CreateReservation.swift
//  lineUpAPI
//
//  Created by Guillaume Richard on 09/10/2026.
//

import Foundation
import Vapor
import Fluent

struct CreateReservation: AsyncMigration {

    func prepare(on database: any Database) async throws {
        try await database.schema("reservations")

    }

    func revert(on database: any Database) async throws {
        try await database.schema("reservations").delete()
    }
}

