//
//  Rservation.swift
//  lineUpAPI
//
//  Created by Guillaume Richard on 09/10/2026.
//

import Foundation
import Vapor
import Fluent

final class Reservation: Model, Content, @unchecked Sendable {
    static let schema = "reservations"

    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "status_reservation")
    var status: String
    
    @Parent(key: "id_user")
    var user: User
    
    init() {}
    
    init(id: UUID? = nil, status: String, user: User) {
        self.id = id
        self.status = status
        self.user = user
    }

}

