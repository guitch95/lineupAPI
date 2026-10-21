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
        categories.get(":categoryID", use: getCategoryById)
        categories.post(use: createCategory)
        categories.delete(":categoryID", use: deleteCategoryById)
    }

    // Helper interne : renvoie le Model, pas le DTO — nécessaire pour .delete(on:)
    private func findCategory(req: Request) async throws -> Category {
        guard let category = try await Category.find(
            req.parameters.get("categoryID"),
            on: req.db
        ) else {
            throw Abort(.notFound)
        }
        return category
    }

    func getAllCategory(req: Request) async throws -> [CategoryDTO] {
        try await Category.query(on: req.db)
            .all()
            .map { $0.toDTO() }
    }

    func getCategoryById(req: Request) async throws -> CategoryDTO {
        let category = try await findCategory(req: req)
        return category.toDTO()
    }

    func createCategory(req: Request) async throws -> Response {
        let input = try req.content.decode(CreateCategoryDTO.self)
        let category = input.toModel()
        try await category.create(on: req.db)

        let response = Response(status: .created)
        try response.content.encode(category.toDTO())
        return response
    }

    func deleteCategoryById(req: Request) async throws -> HTTPResponseStatus {
        let category = try await findCategory(req: req)
        try await category.delete(on: req.db)
        return .noContent
    }
}
