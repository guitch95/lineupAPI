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

    init() {}

}

