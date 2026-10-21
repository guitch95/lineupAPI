//
//  File.swift
//  lineUpAPI
//
//  Created by Apprenant151 on 12/10/2026.

import Foundation
import Fluent
import Vapor

// Entrée — ce que le client envoie pour créer une catégorie
struct CreateCategoryDTO: Content {
    var categoryName: String

    func toModel() -> Category {
        Category(nameCategory: categoryName)
    }
}

// Sortie — ce que le serveur renvoie au client
struct CategoryDTO: Content {
    var id: UUID?
    var categoryName: String
}

extension Category {
    func toDTO() -> CategoryDTO {
        CategoryDTO(id: id, categoryName: nameCategory)
    }
}
