//
//  CategoryController.swift
//  lineUpAPI
//
//  Created by Guillaume Richard on 12/10/2026.
//

import Fluent
import Vapor

struct CategoryController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let categories = routes.grouped("categories")
        categories.get(use: getAllCategory)
        categories.get(use: getCategoryById)
        categories.post(use: createCategory)
        categories.delete(use: deleteCategory)
    }

    func getAllCategory(req: Request) async throws -> [Category] {
        try await Category.query(on: req.db).all()
    }

    func getCategoryById(req: Request) async throws -> Category {
        guard
            let category = try await Category.find(
                req.parameters.get("categoryID"),
                on: req.db
            )
        else {
            throw Abort(.notFound)
        }
        return category
    }

    func createCategory(req: Request) async throws -> Category {
        let category = try req.content.decode(Category.self)
        try await category.create(on: req.db)
        return category
    }

    func deleteCategoryById(req: Request) async throws -> HTTPResponseStatus {
        let workshop = try await getCategoryById(req: req)
        try await workshop.delete(on: req.db)
        return .noContent
    }

}
