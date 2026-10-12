//
//  WorkshopController.swift
//  lineUpAPI
//
//  Created by Guillaume Richard on 09/10/2026.
//

import Foundation
import Vapor
import Fluent

func boot(routes: any RoutesBuilder) throws {
    let workshops = routes.grouped("workshops")
    workshops.get(use:index)
    workshops.post(use: createWorkshop)
    workshops.group(":id") { workshop in
        wokshop.get(use: findWorkshopById)
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
        throw Abort(.notFound, reason: "Auteur introuvable")
    }

    return author
}


func createWorkshop(req: Request) async throws -> Workshop {
    let workshop = try req.content.decode(Workshop.self)
    let authorID = book.$workshop.id
    guard try await Workshop.find(authorID, on: req.db) != nil else {
        throw Abort(.notFound, reason: "Auteur introuvable")
    }

    try await workshop.create(on: req.db)
    return workshop
}

func deleteAWorkshop(req: Request) async throws -> HTTPResponseStatus {
    let workshop = try await getWorkshopByID(req: req)
    try await workshop.delete(on: req.db)
    return .noContent
}

