//
//  WorkshopController.swift
//  lineUpAPI
//
//  Created by Guillaume Richard on 09/10/2026.
//

import Fluent
import Foundation
import Vapor

struct WorkshopController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let workshops = routes.grouped("workshops")
        workshops.get(use: index)
        workshops.post(use: createWorkshop)
        workshops.group(":id") { workshop in
            workshop.get(use: getWorkshopByID)
            workshop.put(use: updateWorkshop)
            workshop.delete(use: deleteAWorkshop)
        }

    }

    func index(req: Request) async throws -> [WorkshopDTO] {
        try await Workshop.query(on: req.db)
            .with(\.$category)
            .all()
            .map { try $0.toDTO() }
    }

    func getWorkshopByID(req: Request) async throws -> WorkshopDTO {
        try await findWorkshop(req: req).toDTO()
    }

    // POST
    func createWorkshop(req: Request) async throws -> WorkshopDTO {

        let input = try req.content.decode(CreateWorkshopDTO.self)

        guard try await Category.find(input.categoryID, on: req.db) != nil
        else {
            throw Abort(.notFound, reason: "Catégorie introuvable")
        }

        guard input.endTimeWorkshop > input.startTimeWorkshop else {
            throw Abort(
                .badRequest,
                reason: "L'heure de fin doit être après l'heure de début"
            )
        }

        guard input.capacityMaxWorkshop > 0 else {
            throw Abort(
                .badRequest,
                reason: "La capacité doit être supérieure à 0"
            )
        }

        let workshop = input.toModel()
        try await workshop.create(on: req.db)
        try await workshop.$category.load(on: req.db)  // le workshop vient d'être créé, sa catégorie n'est pas chargée
        return try workshop.toDTO()

    }

    // PUT
    func updateWorkshop(req: Request) async throws -> WorkshopDTO {
        let input = try req.content.decode(CreateWorkshopDTO.self)
        let workshop = try await findWorkshop(req: req)

        guard try await Category.find(input.categoryID, on: req.db) != nil
        else {
            throw Abort(.badRequest, reason: "Catégorie introuvable")
        }

        guard input.endTimeWorkshop > input.startTimeWorkshop else {
            throw Abort(
                .badRequest,
                reason: "L'heure de fin doit être après l'heure de début"
            )
        }
        guard input.capacityMaxWorkshop >= workshop.subscribersNbWorkshop else {
            throw Abort(
                .conflict,
                reason:
                    "La capacité ne peut pas être inférieure au nombre d'inscrits"
            )
        }

        guard input.capacityMaxWorkshop > 0 else {
            throw Abort(
                .badRequest,
                reason: "La capacité doit être supérieure à 0"
            )
        }

        workshop.$category.id = input.categoryID
        workshop.nameWorkshop = input.nameWorkshop
        workshop.startTimeWorkshop = input.startTimeWorkshop
        workshop.endTimeWorkshop = input.endTimeWorkshop
        workshop.capacityMaxWorkshop = input.capacityMaxWorkshop
        workshop.descriptionWorkshop = input.descriptionWorkshop

        try await workshop.update(on: req.db)
        try await workshop.$category.load(on: req.db)
        return try workshop.toDTO()
    }

    // DELETE
    func deleteAWorkshop(req: Request) async throws -> HTTPResponseStatus {
        let workshop = try await findWorkshop(req: req)
        try await workshop.delete(on: req.db)
        return .noContent
    }

    // Helper
    private func findWorkshop(req: Request) async throws -> Workshop {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Entrez un id valide")
        }
        guard
            let workshop = try await Workshop.query(on: req.db)
                .filter(\.$id == id)
                .with(\.$category)
                .first()
        else {
            throw Abort(.notFound, reason: "Workshop introuvable")
        }
        return workshop
    }
}
