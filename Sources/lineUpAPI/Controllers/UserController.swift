//
//  UserController.swift
//  lineUpAPI
//
//  Created by Guillaume Richard on 09/10/2026.
//

import Fluent
import Vapor

struct UserController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let users = routes.grouped("users")
        users.post(use: create)

        let protected = users.grouped(JWTMiddleware())
        protected.get(use: index)
        protected.group(":id") { user in
            user.get(use: show)
            user.patch(use: patch)
            user.delete(use: delete)
        }
    }

    // Récupère tous les utilisateurs : GET/users
    func index(req: Request) async throws -> [UserDTO] {
        let payload = try req.auth.require(UserPayload.self)

        // Charger le user connecté pour connaître son rôle actuel
        guard let currentUser = try await User.find(payload.id, on: req.db)
        else {
            throw Abort(.unauthorized, reason: "Utilisateur introuvable.")
        }

        // Seul le staff peut voir tous les comptes
        guard currentUser.role == .staff else {
            throw Abort(.forbidden, reason: "Accès réservé au staff.")
        }

        let users = try await User.query(on: req.db)
            .all()

        return try users.map { try $0.toDTO() }
    }

    // Créer un utilisateur : POST/users
    func create(req: Request) async throws -> UserDTO {
        try CreateUserDTO.validate(content: req)

        let dto = try req.content.decode(CreateUserDTO.self)

        let emailAlreadyUsed =
            try await User.query(on: req.db)
            .filter(\.$email == dto.email)
            .first() != nil
        if emailAlreadyUsed {
            throw Abort(.conflict, reason: "Cet email est déjà utilisé.")
        }
        let passwordHash = try Bcrypt.hash(dto.password)
        let user = dto.toModel(passwordHash: passwordHash)
        try await user.create(on: req.db)
        return try user.toDTO()
    }

    // Affiche un utilisateur en passant en paramètre l'id de l'utilisateur : GET/users/:id
    func show(req: Request) async throws -> UserDTO {
        let payload = try req.auth.require(UserPayload.self)

        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "ID invalide")
        }

        if id != payload.id {
            guard let currentUser = try await User.find(payload.id, on: req.db),
                currentUser.role == .staff
            else {
                throw Abort(.forbidden, reason: "Accès refusé.")
            }
        }

        guard let user = try await User.find(id, on: req.db) else {
            throw Abort(.notFound)
        }

        return try user.toDTO()
    }

    // Modifie partiellement les infos de l'utilisateur : PATCH/users/:id
    func patch(req: Request) async throws -> UserDTO {
        let payload = try req.auth.require(UserPayload.self)

        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "ID invalide")
        }

        // On ne peut modifier que son propre compte
        guard id == payload.id else {
            throw Abort(
                .forbidden,
                reason: "Vous ne pouvez modifier que votre propre compte."
            )
        }

        guard let user = try await User.find(id, on: req.db) else {
            throw Abort(.notFound)
        }

        try UpdateUserDTO.validate(content: req)
        let data = try req.content.decode(UpdateUserDTO.self)

        if let name = data.name {
            user.name = name
        }

        if let email = data.email,
            email != user.email
        {
            let emailAlreadyUsed =
                try await User.query(on: req.db)
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
        let payload = try req.auth.require(UserPayload.self)

        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "ID invalide")
        }

        // Un autre compte que le sien : seul le staff y a accès
        if id != payload.id {
            guard let currentUser = try await User.find(payload.id, on: req.db),
                currentUser.role == .staff
            else {
                throw Abort(.forbidden, reason: "Accès refusé.")
            }
        }

        guard let user = try await User.find(id, on: req.db) else {
            throw Abort(.notFound)
        }

        // Libérer les places des ateliers réservés par l'utilisateur.
        // Ses réservations sont ensuite supprimées par la base (onDelete: .cascade),
        // qui ne met pas à jour le nombre d'inscrits.
        let reservations = try await Reservation.query(on: req.db)
            .filter(\.$user.$id == id)
            .with(\.$workshop)
            .all()

        for reservation in reservations {
            let workshop = reservation.workshop
            if workshop.subscribersNbWorkshop > 0 {
                workshop.subscribersNbWorkshop -= 1
                try await workshop.update(on: req.db)
            }
        }

        try await user.delete(on: req.db)

        return .noContent
    }
}
