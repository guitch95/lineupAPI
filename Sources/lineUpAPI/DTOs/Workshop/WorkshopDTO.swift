//
//  WorkshopDTO.swift
//  lineUpAPI
//
//  Created by Guillaume Richard on 22/10/2026.
//

import Fluent
import Vapor

struct WorkshopDTO: Content {
    var id: UUID
    var name: String
    var startTime: Date
    var endTime: Date
    var capacityMax: Int
    var subscribersNb: Int
    var description: String
    var category: CategoryDTO
}

extension Workshop {
    func toDTO() throws -> WorkshopDTO {
        WorkshopDTO(
            id: try requireID(),
            name: nameWorkshop,
            startTime: startTimeWorkshop,
            endTime: endTimeWorkshop,
            capacityMax: capacityMaxWorkshop,
            subscribersNb: subscribersNbWorkshop,
            description: descriptionWorkshop,
            category: category.toDTO()
        )
    }
}
