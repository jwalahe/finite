//
//  Week.swift
//  Finite
//
//  Created by Jwala Kompalli on 12/15/25.
//

import Foundation
import SwiftData

@Model
final class Week {
    var weekNumber: Int
    var rating: Int?
    var categoryRawValue: String?
    var phrase: String?
    var markedAt: Date?

    init(weekNumber: Int) {
        self.weekNumber = weekNumber
    }

    var category: WeekCategory? {
        get {
            guard let rawValue = categoryRawValue else { return nil }
            return WeekCategory(rawValue: rawValue)
        }
        set {
            categoryRawValue = newValue?.rawValue
        }
    }
}
