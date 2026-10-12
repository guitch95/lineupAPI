//
//  Category.swift
//  lineUpAPI
//
//  Created by Guillaume Richard on 12/10/2026.
//

import Foundation
import Vapor
import Fluent

final class Category: Model, Content, @unchecked Sendable {
    static let schema = "categories"

    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name_category")
    var nameCategory: String
    
    @Children(for: \.$category)
    var workshops: [Workshop]

    init() {}
    
    init(id: UUID? = nil, nameCategory: String) {
        self.id = id
        self.nameCategory = nameCategory
    }

}

