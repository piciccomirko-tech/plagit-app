//
//  PlagitConstants.swift
//  Plagit
//
//  Predefined roles and job types for matching.
//

import Foundation

enum PlagitRole: String, CaseIterable, Identifiable {
    case chef = "Chef"
    case sousChef = "Sous Chef"
    case waiter = "Waiter"
    case bartender = "Bartender"
    case barista = "Barista"
    case hostess = "Hostess"
    case runner = "Runner"
    case receptionist = "Receptionist"
    case kitchenPorter = "Kitchen Porter"
    case manager = "Manager"
    case sommelier = "Sommelier"
    case housekeeper = "Housekeeper"
    case concierge = "Concierge"
    case roomAttendant = "Room Attendant"

    var id: String { rawValue }
    var label: String { rawValue }
    var icon: String {
        switch self {
        case .chef, .sousChef: return "flame"
        case .waiter, .runner: return "fork.knife"
        case .bartender: return "wineglass"
        case .barista: return "cup.and.saucer"
        case .hostess, .receptionist, .concierge: return "person.wave.2"
        case .kitchenPorter: return "sink"
        case .manager: return "person.badge.key"
        case .sommelier: return "wineglass.fill"
        case .housekeeper, .roomAttendant: return "bed.double"
        }
    }
}

enum PlagitJobType: String, CaseIterable, Identifiable {
    case fullTime = "Full-time"
    case partTime = "Part-time"
    case flexible = "Flexible"

    var id: String { rawValue }
    var label: String { rawValue }
    var icon: String {
        switch self {
        case .fullTime: return "clock.fill"
        case .partTime: return "clock.badge.checkmark"
        case .flexible: return "arrow.2.squarepath"
        }
    }
}
