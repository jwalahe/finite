//
//  WeekCategory.swift
//  Finite
//
//  Created by Jwala Kompalli on 12/15/25.
//

import Foundation

enum WeekCategory: String, Codable, CaseIterable {
    case work
    case health
    case growth
    case relationships
    case rest
    case adventure

    var displayName: String {
        switch self {
        case .work: return "Work"
        case .health: return "Health"
        case .growth: return "Growth"
        case .relationships: return "Relationships"
        case .rest: return "Rest"
        case .adventure: return "Adventure"
        }
    }

    var iconName: String {
        switch self {
        case .work: return "briefcase.fill"
        case .health: return "heart.fill"
        case .growth: return "book.fill"
        case .relationships: return "person.2.fill"
        case .rest: return "moon.fill"
        case .adventure: return "airplane"
        }
    }
}
