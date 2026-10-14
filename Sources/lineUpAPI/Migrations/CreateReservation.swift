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
        try await database.schema(Reservation.schema)
            .id()
            .field("status_reservation", .string, .required)
            .field("id_user", .uuid, .required, .references(User.schema, "id", onDelete: .cascade))
            .field("id_workshop", .uuid, .required, .references(Workshop.schema, "id", onDelete: .cascade))
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema(Reservation.schema)
            .delete()
    }
}

