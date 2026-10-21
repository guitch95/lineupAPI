//
//  File.swift
//  lineUpAPI
//
//  Created by Guillaume Richard on 21/10/2026.
//

import Fluent
import Vapor
import JWT

struct AuthController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let auth = routes.grouped("auth")
        auth.post("login", use: login)

    }

    func login(req: Request) async throws -> TokenResponseDTO {
        // Décoder les données utilisateur à partir de la requête
        let dto = try req.content.decode(LoginDTO.self)

        // Rechercher l'utilisateur par email
        guard let user = try await User.query(on: req.db)
            .filter(\.$email == dto.email)
            .first() else {
            throw Abort(.unauthorized, reason: "Email ou mot de passe incorrect.") // L'utilisateur n'existe pas
        }

        // Vérification du mot de passe
        guard try Bcrypt
            .verify(dto.password, created: user.passwordHash) else {
            throw Abort(.unauthorized, reason: "Email ou mot de passe incorrect.") // Mot de passe incorrect
        }

        // Génération du token JWT
        // try : requireID() échoue si le user n'a pas d'id (normalement impossible pour un user venant de la base)
        let payload = UserPayload(id: try user.requireID())
        // et sign échoue si la signature rate.
        let token = try await req.jwt.sign(payload)
        return TokenResponseDTO(token: token)
    }


}



