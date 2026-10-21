//
//  File.swift
//  lineUpAPI
//
//  Created by Canessane Ramya on 14/10/2026.
//

import Fluent
import Vapor

struct CreateReservationDTO: Content {
    let userID: UUID
    let workshopID: UUID
    
    func toModel() -> Reservation {
        let reservation = Reservation(
            status: .validee,
            userID: userID,
            workshopID: workshopID,
        )
        return reservation
    }
}
