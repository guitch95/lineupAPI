//
//  File.swift
//  lineUpAPI
//
//  Created by Guillaume Richard on 21/10/2026.
//

import Fluent
import Vapor

struct AuthController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let auth = routes.grouped("auth")
        auth.post("login", use: login)

    }

    func login(req: Request) async throws -> UserDTO {
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

        return try user.toDTO()

//        // Génération du token JWT
//        let payload = UtilisateurPayload(id: utilisateur.id!)
//        let signer = JWTSigner.hs256(key: "votre_clé_secrète") // Utilisez une clé secrète sécurisée
//        let token = try signer.sign(payload) // Signer le payload pour générer le token
//        return token // Retourner le token au client
    }


}



