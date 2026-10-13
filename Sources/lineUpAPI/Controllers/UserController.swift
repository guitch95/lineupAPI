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
        users.group(":id") { user in
            users.get(use: show)
            users.patch(use: patch)
            users.delete(use: delete)
        }
    }
    
    func index(req: Request) async throws -> [UserDTO] {
        let users = try await User.query(on: req.db)
            .all()

        return try users.map { try $0.toDTO() }
    }
    
    func create(req: Request) async throws -> UserDTO {
        let dto = try req.content.decode(CreateUserDTO.self)
        let user = dto.toModel()
        try await user.create(on: req.db)
        return try user.toDTO()
    }
    
    func show(req: Request) async throws -> UserDTO {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "ID invalide")
        }
        
        guard let user = try await User.find(id, on: req.db) else {
            throw Abort(.notFound)
        }
        
        return try user.toDTO()
    }
    
    func patch(req: Request) async throws -> UserDTO {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "ID invalide")
        }
        
        guard let user = try await  User.find(id, on: req.db) else {
            throw Abort(.notFound)
        }
        
        let data = try req.content.decode(UpdateUserDTO.self)
        
        if let name = data.name {
            user.name = name
        }
        
        if let email = data.email {
            user.email = email
        }
        
        try await user.update(on: req.db)
        
        return try user.toDTO()
    }
    
    func delete(req: Request) async throws -> HTTPStatus {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "ID invalide")
        }
        
        guard let user = try await User.find(id, on: req.db) else {
            throw Abort(.notFound)
        }
        
        try await user.delete(on: req.db)
        
        return .noContent
    }
}

