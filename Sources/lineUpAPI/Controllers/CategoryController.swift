//
//  CategoryController.swift
//  lineUpAPI
//
//  Created by Guillaume Richard on 12/10/2026.
//

import Foundation

import Foundation
import Vapor

struct CategoryController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let shows = routes.grouped("categories")
        //        shows.get()

    }
    //    func index(req: Request) async throws [User] {}

}
