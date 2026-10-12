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
    
    
}


