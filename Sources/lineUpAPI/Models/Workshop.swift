//
//  Workshop.swift
//  lineUpAPI
//
//  Created by Guillaume Richard on 09/10/2026.
//

import Foundation
import Vapor
import Fluent

final class Workshop: Model, Content, @unchecked Sendable {
    static let schema = "workshops"

    @ID(key: .id)
    var id: UUID?

    init() {}

}

