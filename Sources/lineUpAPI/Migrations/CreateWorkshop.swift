//
//  File.swift
//  lineUpAPI
//
//  Created by Guillaume Richard on 09/10/2026.
//

import Fluent
import FluentSQL

struct CreateWorkshop: AsyncMigration {

    func prepare(on database: any Database) async throws {
        try await database.schema("workshops")
            .id()
            .field("name_workshop", .string, .required)
            .field("start_time_workshop", .datetime, .required)
            .field("end_time_workshop", .datetime, .required)
            .field("capacity_max_workshop", .int, .required)
            .field("subscribers_nb_workshop", .int, .required, .sql(.default(0)))
            .field("description_workshop", .string, .required)
            .field(
                "category_id",
                .uuid,
                .required,
                .references(Category.schema, "id")
            )
            .create()

    }

    func revert(on database: any Database) async throws {
        try await database.schema("workshops").delete()
    }
}

