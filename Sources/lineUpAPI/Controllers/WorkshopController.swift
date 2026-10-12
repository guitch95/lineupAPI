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

    func index(req: Request) async throws -> [Workshop] {
        try await Workshop.query(on: req.db).all()
    }

    func getWorkshopByID(req: Request) async throws -> Workshop {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Entrez un id valide")
        }

        guard let workshop = try await Workshop.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "Workshop introuvable")
        }

        return workshop
    }

    // POST
    func createWorkshop(req: Request) async throws -> Workshop {
        let input = try req.content.decode(CreateWorkshopDTO.self)

        guard try await Category.find(input.categoryID, on: req.db) != nil else {
            throw Abort(.notFound, reason: "Catégorie introuvable")
        }

        guard input.endTimeWorkshop > input.startTimeWorkshop else {
                throw Abort(.badRequest, reason: "L'heure de fin doit être après l'heure de début")
        }

        guard input.capacityMaxWorkshop > 0 else {
                throw Abort(.badRequest, reason: "La capacité doit être supérieure à 0")
        }


        let workshop = Workshop(
            nameWorkshop: input.nameWorkshop,
            startTimeWorkshop: input.startTimeWorkshop,
            endTimeWorkshop: input.endTimeWorkshop,
            capacityMaxWorkshop: input.capacityMaxWorkshop,
            descriptionWorkshop: input.descriptionWorkshop,
            categoryID: input.categoryID
        )

        try await workshop.create(on: req.db)
        return workshop

    }

    // PUT
    func updateWorkshop(req: Request) async throws -> Workshop {
        let input = try req.content.decode(CreateWorkshopDTO.self)
        let workshop = try await getWorkshopByID(req: req)

        guard try await Category.find(input.categoryID, on: req.db) != nil else {
            throw Abort(.badRequest, reason: "Catégorie introuvable")
        }

        guard input.endTimeWorkshop > input.startTimeWorkshop else {
            throw Abort(.badRequest, reason: "L'heure de fin doit être après l'heure de début")
        }
        guard input.capacityMaxWorkshop >= workshop.subscribersNbWorkshop else {
            throw Abort(.conflict, reason: "La capacité ne peut pas être inférieure au nombre d'inscrits")
        }

        guard input.capacityMaxWorkshop > 0 else {
            throw Abort(.badRequest, reason: "La capacité doit être supérieure à 0")
        }

        workshop.$category.id = input.categoryID
        workshop.nameWorkshop = input.nameWorkshop
        workshop.startTimeWorkshop = input.startTimeWorkshop
        workshop.endTimeWorkshop = input.endTimeWorkshop
        workshop.capacityMaxWorkshop = input.capacityMaxWorkshop
        workshop.descriptionWorkshop = input.descriptionWorkshop


        try await workshop.update(on: req.db)
        return workshop
    }

    // DELETE
    func deleteAWorkshop(req: Request) async throws -> HTTPResponseStatus {
        let workshop = try await getWorkshopByID(req: req)
        try await workshop.delete(on: req.db)
        return .noContent
    }
}
