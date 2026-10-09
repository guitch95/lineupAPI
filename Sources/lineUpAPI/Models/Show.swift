//
//  Show.swift
//  lineUpAPI
//
//  Created by Guillaume Richard on 09/10/2026.
//

import Foundation
import Vapor
import Fluent

final class Show: Model, Content, @unchecked Sendable {
    static let schema = "shows"

    @ID(key: .id)
    var id: UUID?

    init() {}

}

