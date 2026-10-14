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
        let reservations = routes.grouped("reservations")
        reservations.get(use: index)
        reservations.post(use: create)
        reservations.get("user", ":userID", use: getUserReservations)
        reservations.delete(":id", use: delete)
    }
    func index(req: Request) async throws -> [ReservationDTO] {
        let reservations = try await Reservation.query(on: req.db)
            .with(\.$workshop)
            .all()
            
        return try reservations.map { try $0.toDTO() }
    }
    
    func create(req: Request) async throws -> ReservationDTO {
        let dto = try req.content.decode(CreateReservationDTO.self)
        
        guard let workshop = try await Workshop.find(dto.workshopID, on: req.db) else {
            throw Abort(.notFound, reason: "Atelier introuvable")
        }
        
        guard workshop.subscribersNbWorkshop < workshop.capacityMaxWorkshop else {
            throw Abort(.conflict, reason: "L'atelier est complet")
        }
        
        let reservation = dto.toModel()
        try await reservation.create(on: req.db)
        
        // Mettre à jour le nombre d'inscrits sur l'atelier
        workshop.subscribersNbWorkshop += 1
        try await workshop.update(on: req.db)
        
        // Charger la relation workshop pour générer le DTO complet de retour
        reservation.$workshop.value = workshop
        return try reservation.toDTO()
    }
    
    func getUserReservations(req: Request) async throws -> [ReservationDTO] {
        guard let userID = req.parameters.get("userID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "ID utilisateur invalide")
        }
        
        let reservations = try await Reservation.query(on: req.db)
            .filter(\.$user.$id == userID)
            .filter(\.$status == .validee)
            .with(\.$workshop)
            .all()
        
        return try reservations.map { try $0.toDTO() }
    }
    
    func delete(req: Request) async throws -> HTTPStatus {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "ID réservation invalide")
        }
        
        guard let reservation = try await Reservation.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "Réservation introuvable")
        }
        
        // Récupérer l'atelier associé pour décrémenter les inscrits
        if let workshop = try await Workshop.find(reservation.$workshop.id, on: req.db) {
            if workshop.subscribersNbWorkshop > 0 {
                workshop.subscribersNbWorkshop -= 1
                try await workshop.update(on: req.db)
            }
        }
        
        try await reservation.delete(on: req.db)
        
        return .noContent
    }
}
