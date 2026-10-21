//
//  EnumReservation.swift
//  lineUpAPI
//
//  Created by Apprenant123 on 14/10/2026.
//

import Foundation
import Vapor

enum ReservationStatus: String, Codable, CaseIterable {
    case validee = "validée"
    case enAttente = "en attente"
    case annulee = "annulée"
}
