//
//  File.swift
//  lineUpAPI
//
//  Created by Canessane Ramya on 14/10/2026.
//

import Fluent
import Vapor

struct ReservationDTO: Content {
    let id: UUID?
    let userID: UUID
    let status: ReservationStatus
    
    let nameWorkshop: String
    let startTimeWorkshop: Date
    let endTimeWorkshop: Date
}

extension Reservation {
    func toDTO() throws -> ReservationDTO {
        
        guard let workshop = self.$workshop.value else {
            throw Abort(.internalServerError, reason: "L'atelier associé n'a pas été chargé.")
        }
        
        return ReservationDTO(
            id: try requireID(),
            userID: self.$user.id,
            status: self.status,
            nameWorkshop: workshop.nameWorkshop,
            startTimeWorkshop: workshop.startTimeWorkshop,
            endTimeWorkshop: workshop.endTimeWorkshop
        )
    }
}
