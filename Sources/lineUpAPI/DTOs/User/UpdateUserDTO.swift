//
//  UpdateUserDTO.swift
//  lineUpAPI
//
//  Created by Apprenant123 on 14/10/2026.
//
import Fluent
import Vapor

struct UpdateUserDTO: Content, Validatable {
    var name: String?
    var email: String?
    
    static func validations(_ validations: inout Validations) {
            validations.add("name", as: String.self, is: !.empty && .count(...50), required: false)
            validations.add("email", as: String.self, is: .email && .count(...100), required: false)
        }
    
}
