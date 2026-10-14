//
//  CreateUserDTO.swift
//  lineUpAPI
//
//  Created by Apprenant123 on 14/10/2026.
//
import Fluent
import Vapor

struct CreateUserDTO: Content, Validatable {
    var name: String
    var email: String
    var passwordHash: String
    var role: UserRole // TODO (après le cours auth) : retirer role du DTO et forcer .festivalier
    
    static func validations(_ validations: inout Validations) {
            validations.add("name", as: String.self, is: !.empty && .count(...50))
            validations.add("email", as: String.self, is: .email && .count(...100))
            validations.add("password", as: String.self, is: .count(8...))
        }
    
    func toModel() -> User {
        User(
            name: name,
            email: email,
            passwordHash: passwordHash,
            role: role
        )
    }
}
