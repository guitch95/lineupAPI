//
//  ReservationController.swift
//  lineUpAPI
//
//  Created by Guillaume Richard on 09/10/2026.
//

import Foundation
import Vapor

struct ReservationController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let reservations = routes.grouped("reservations")

    }

}
