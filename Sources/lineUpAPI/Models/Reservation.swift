//
//  Rservation.swift
//  lineUpAPI
//
//  Created by Guillaume Richard on 09/10/2026.
//

import Vapor
import Fluent

final class Reservation: Model, Content, @unchecked Sendable {
    static let schema = "reservations"

    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "status_reservation")
    var status: ReservationStatus
    
    @Parent(key: "id_user")
    var user: User
    
    @Parent(key: "id_workshop")
    var workshop: Workshop
    
    init() {}
    
    init(id: UUID? = nil, status: ReservationStatus, userID: UUID, workshopID: UUID) {
        self.id = id
        self.status = status
        self.$user.id = userID
        self.$workshop.id = workshopID
    }
}

