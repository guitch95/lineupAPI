//
//  StaffMiddleware.swift
//  lineUpAPI
//
//  Created by Guillaume Richard on 26/10/2026.
//

import Vapor
import Fluent

// Vérification du rôle de staff pour protection de certaines routes.

struct StaffMiddleware: AsyncMiddleware {
    func respond(to req: Request, chainingTo next: any AsyncResponder) async throws -> Response {
        let payload = try req.auth.require(UserPayload.self)

        guard let user = try await User.find(payload.id, on: req.db) else {
            throw Abort(.unauthorized, reason: "Utilisateur introuvable")
        }

        guard user.role == .staff else {
            throw Abort(.forbidden, reason: "Accès réservé au staff.")
        }
        return try await next.respond(to: req)
    }
}
