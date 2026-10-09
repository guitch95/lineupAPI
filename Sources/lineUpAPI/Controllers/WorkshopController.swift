//
//  WorkshopController.swift
//  lineUpAPI
//
//  Created by Guillaume Richard on 09/10/2026.
//

import Foundation
import Vapor
import Fluent

struct WorkshopController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let workshops = routes.grouped("workshops")
//        workshops.get()

    }
//    func index(req: Request) async throws [Workshop] {}

}

