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
            user.get(use: show)
            user.patch(use: patch)
            user.delete(use: delete)
        }
    }
    
    // Récupère tous les utilisateurs : GET/users
    func index(req: Request) async throws -> [UserDTO] {
        let users = try await User.query(on: req.db)
            .all()
        
        return try users.map { try $0.toDTO() }
    }
    
    // Créer un utilisateur : POST/users
    func create(req: Request) async throws -> UserDTO {
        try CreateUserDTO.validate(content: req)
        
        let dto = try req.content.decode(CreateUserDTO.self)
        
        let emailAlreadyUsed = try await User.query(on: req.db)
            .filter(\.$email == dto.email)
            .first() != nil
        if emailAlreadyUsed {
            throw Abort(.conflict, reason: "Cet email est déjà utilisé.")
        }
        
        let user = dto.toModel()
        try await user.create(on: req.db)
        return try user.toDTO()
    }
    
    // Affiche un utilisateur en passant en paramètre l'id de l'utilisateur : GET/users/:id
    func show(req: Request) async throws -> UserDTO {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "ID invalide")
        }
        
        guard let user = try await User.find(id, on: req.db) else {
            throw Abort(.notFound)
        }
        
        return try user.toDTO()
    }
    
    // Modifie partiellement les infos de l'utilisateur : PATCH/users/:id
    func patch(req: Request) async throws -> UserDTO {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "ID invalide")
        }
        
        guard let user = try await  User.find(id, on: req.db) else {
            throw Abort(.notFound)
        }
        
        try UpdateUserDTO.validate(content: req)
        let data = try req.content.decode(UpdateUserDTO.self)
        
        if let name = data.name {
            user.name = name
        }
        
        if let email = data.email, email != user.email {
            let emailAlreadyUsed = try await User.query(on: req.db)
                .filter(\.$email == email)
                .first() != nil
            if emailAlreadyUsed {
                throw Abort(.conflict, reason: "Cet email est déjà utilisé.")
            }
            user.email = email
        }
        
        try await user.update(on: req.db)
        
        return try user.toDTO()
    }
    
    // Supprimer un utilisateur : DELETE/users/:id
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

