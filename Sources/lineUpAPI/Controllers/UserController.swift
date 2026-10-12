//
//  UserController.swift
//  lineUpAPI
//
//  Created by Guillaume Richard on 09/10/2026.
//

import Vapor
import Fluent

struct UserController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let users = routes.grouped("users")
        users.get(use: index)
        users.post(use: create)
        users.get(":id", use: show)
        users.put(":id", use: update)
    }
    
    func index(req: Request) async throws -> [User] {
        return try await User
            .query(on: req.db)
            .all()
    }
    
    func create(req: Request) async throws -> User {
        let user = try req.content.decode(User.self)
        try await user.create(on: req.db)
        return user
    }
    
    func show(req: Request) async throws -> User {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "ID invalide")
        }
        
        guard let user = try await User.find(id, on: req.db) else {
            throw Abort(.notFound)
        }
        
        return user
    }
    
    func update(req: Request) async throws -> User {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "ID invalide")
        }
        
        guard let user = try await  User.find(id, on: req.db) else {
            throw Abort(.notFound)
        }
        
        let newUser = try req.content.decode(User.self)
        
        user.name = newUser.name
        user.email = newUser.email
        user.passwordHash = newUser.passwordHash
        user.role = newUser.role
        user.createdAt = newUser.createdAt
        user.reservations = newUser.reservations
        
        return user
    }
}

