//
//  File.swift
//  lineUpAPI
//
//  Created by Apprenant151 on 12/10/2026.

import Foundation
import Fluent
import Vapor

struct CreateCategoryDTO: Content {
    var categoryName: String
    
    func toModel() -> Category {
        let category = Category(nameCategory: categoryName)
        return category
    }
}


