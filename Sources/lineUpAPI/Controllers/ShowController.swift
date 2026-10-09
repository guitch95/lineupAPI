//
//  ShowController.swift
//  lineUpAPI
//
//  Created by Guillaume Richard on 09/10/2026.
//

import Foundation
import Vapor

struct ShowController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let shows = routes.grouped("shows")
        //        shows.get()

    }
    //    func index(req: Request) async throws [User] {}

}
