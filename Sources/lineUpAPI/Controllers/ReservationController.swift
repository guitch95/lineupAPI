//
//  ReservationController.swift
//  lineUpAPI
//
//  Created by Guillaume Richard on 09/10/2026.
//

import Fluent
import Vapor

struct ReservationController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let reservations = routes.grouped("reservations").grouped(
            JWTMiddleware()
        )
        reservations.get(use: index)
        reservations.post(use: create)
        reservations.get("me", use: getMyReservations)
        reservations.delete(":id", use: delete)
    }

    // Récupère toutes les réservations : GET/reservations
    func index(req: Request) async throws -> [ReservationDTO] {
        let payload = try req.auth.require(UserPayload.self)

        // Charger le user pour connaître son rôle actuel
        guard let user = try await User.find(payload.id, on: req.db) else {
            throw Abort(.unauthorized, reason: "Utilisateur introuvable.")
        }

        // Seul le staff peut voir toutes les réservations
        guard user.role == .staff else {
            throw Abort(.forbidden, reason: "Accès réservé au staff.")
        }

        let reservations = try await Reservation.query(on: req.db)
            .with(\.$workshop)
            .all()

        return try reservations.map { try $0.toDTO() }
    }

    // Créer une réservation :  POST/reservations
    func create(req: Request) async throws -> ReservationDTO {
        let payload = try req.auth.require(UserPayload.self)
        let dto = try req.content.decode(CreateReservationDTO.self)

        guard let workshop = try await Workshop.find(dto.workshopID, on: req.db)
        else {
            throw Abort(.notFound, reason: "Atelier introuvable")
        }

        guard workshop.subscribersNbWorkshop < workshop.capacityMaxWorkshop
        else {
            throw Abort(.conflict, reason: "L'atelier est complet")
        }

        let reservation = dto.toModel(userID: payload.id)
        try await reservation.create(on: req.db)

        // Mettre à jour le nombre d'inscrits sur l'atelier
        workshop.subscribersNbWorkshop += 1
        try await workshop.update(on: req.db)

        // Charger la relation workshop pour générer le DTO complet de retour
        reservation.$workshop.value = workshop
        return try reservation.toDTO()
    }

    // Récupérer la réservation d'un utilisateur : GET/reservations/me
    func getMyReservations(req: Request) async throws -> [ReservationDTO] {
        let payload = try req.auth.require(UserPayload.self)
        let reservations = try await Reservation.query(on: req.db)
            .filter(\.$user.$id == payload.id)
            .filter(\.$status == .validee)
            .with(\.$workshop)
            .all()

        return try reservations.map { try $0.toDTO() }
    }

    // Supprimer une réservation : DELETE/reservations/:id
    func delete(req: Request) async throws -> HTTPStatus {
        let payload = try req.auth.require(UserPayload.self)
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "ID réservation invalide")
        }

        guard let reservation = try await Reservation.find(id, on: req.db)
        else {
            throw Abort(.notFound, reason: "Réservation introuvable")
        }

        guard reservation.$user.id == payload.id else {
            throw Abort(
                .forbidden,
                reason: "Cette réservation ne vous appartient pas"
            )
        }

        // Récupérer l'atelier associé pour décrémenter les inscrits
        if let workshop = try await Workshop.find(
            reservation.$workshop.id,
            on: req.db
        ) {
            if workshop.subscribersNbWorkshop > 0 {
                workshop.subscribersNbWorkshop -= 1
                try await workshop.update(on: req.db)
            }
        }

        try await reservation.delete(on: req.db)

        return .noContent
    }
}
