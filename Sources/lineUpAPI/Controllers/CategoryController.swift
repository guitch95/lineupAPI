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
        categories.get(use: index)
        categories.get(use: show)
        categories.post(use: createCategory)
        categories.delete(":categoryID", use: deleteCategoryById)
    }


    func index(req: Request) async throws -> [Category] {
        try await Category.query(on: req.db).all()
    }

    func show(req: Request) async throws -> Category {
        guard let category = try await Category.find(
            req.parameters.get("categoryID"), on: req.db
        ) else {
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
        let category = try await show(req: req)
        try await category.delete(on: req.db)
        return .noContent
    }


    
}


