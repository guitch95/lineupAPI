//
//  File.swift
//  lineUpAPI
//
//  Created by Canessane Ramya on 14/10/2026.
//

import Fluent
import Vapor

struct CreateReservationDTO: Content {
    let workshopID: UUID
    
    func toModel(userID: UUID) -> Reservation {
        Reservation(
            status: .validee,
            userID: userID, // vient du paramètre donc du token
            workshopID: workshopID,
        )
    }
}
