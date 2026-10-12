//
//  Workshop.swift
//  lineUpAPI
//
//  Created by Guillaume Richard on 09/10/2026.
//

import Fluent
import Foundation
import Vapor

final class Workshop: Model, Content, @unchecked Sendable {
    static let schema = "workshops"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name_workshop")
    var nameWorkshop: String

    @Field(key: "start_time_workshop")
    var startTimeWorkshop: Date

    @Field(key: "end_time_workshop")
    var endTimeWorkshop: Date

    @Field(key: "capacity_max_workshop")
    var capacityMaxWorkshop: Int

    @Field(key: "subscribers_nb_workshop")
    var subscribersNbWorkshop: Int

    @Field(key: "description_workshop")
    var descriptionWorkshop: String

    @Parent(key: "category_id")
    var category: Category

    init() {}

    init(
        id: UUID? = nil,
        nameWorkshop: String,
        startTimeWorkshop: Date,
        endTimeWorkshop: Date,
        capacityMaxWorkshop: Int,
        subscribersNbWorkshop: Int = 0,
        descriptionWorkshop: String,
        categoryID: UUID
    ) {
        self.id = id
        self.nameWorkshop = nameWorkshop
        self.startTimeWorkshop = startTimeWorkshop
        self.endTimeWorkshop = endTimeWorkshop
        self.capacityMaxWorkshop = capacityMaxWorkshop
        self.subscribersNbWorkshop = subscribersNbWorkshop
        self.descriptionWorkshop = descriptionWorkshop
        self.$category.id = categoryID
    }

}
