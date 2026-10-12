//
//  CreateWorkshopDTO.swift
//  lineUpAPI
//
//  Created by Guillaume Richard on 12/10/2026.
//

import Foundation
import Fluent
import Vapor

struct CreateWorkshopDTO: Content {
    var nameWorkshop: String
    var startTimeWorkshop: Date
    var endTimeWorkshop: Date
    var capacityMaxWorkshop: Int
    var descriptionWorkshop: String
    var categoryID: UUID

    func toModel() -> Workshop {
        Workshop(
            nameWorkshop: nameWorkshop,
            startTimeWorkshop: startTimeWorkshop,
            endTimeWorkshop: endTimeWorkshop,
            capacityMaxWorkshop: capacityMaxWorkshop,
            descriptionWorkshop: descriptionWorkshop,
            categoryID: categoryID
        )
    }
}
