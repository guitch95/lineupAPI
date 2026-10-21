//
//  LoginDTO.swift
//  lineUpAPI
//
//  Created by Guillaume Richard on 21/10/2026.
//

import Foundation
import Vapor

struct LoginDTO: Content, Validatable {
    let email: String
    let password: String


    static func validations(_ validations: inout Validations) {
        validations.add("email", as: String.self, is: .email && .count(...100))
    }
}
