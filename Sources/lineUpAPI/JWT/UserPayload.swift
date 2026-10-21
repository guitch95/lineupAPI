//
//  File.swift
//  lineUpAPI
//
//  Created by Guillaume Richard on 21/10/2026.
//

import JWT
import Vapor

struct UserPayload: JWTPayload, Authenticatable {
    var id: UUID
    var expiration: Date

    // JWT 5 : `some JWTAlgorithm` au lieu de `JWTSigner`
    func verify(using algorithm: some JWTAlgorithm) async throws {
        guard expiration > .now else {
            throw Abort(.unauthorized, reason: "Token expiré.") // refusé si la date est dépassée
        }
    }

    // Initialisateur qui définit l'ID et la date d'expiration
    init(id: UUID) {
        self.id = id
        self.expiration = .now.addingTimeInterval(60 * 60 * 24)   // 24h
    }

}




