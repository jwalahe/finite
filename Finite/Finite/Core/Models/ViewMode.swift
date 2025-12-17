//
//  ViewMode.swift
//  Finite
//
//  Three lenses for viewing your life grid
//

import Foundation

/// The three view modes for the life grid
/// Each mode shows the same weeks but with different color meanings
enum ViewMode: String, Codable, CaseIterable {
    /// Chapters mode: Weeks colored by life phase (College=indigo, Career=teal, etc.)
    case chapters

    /// Quality mode: Weeks colored by rating spectrum (1-5, red to green)
    case quality

    /// Focus mode: B&W only, mortality confrontation
    case focus

    /// Display name for the mode label flash
    var displayName: String {
        switch self {
        case .chapters: return "Chapters"
        case .quality: return "Quality"
        case .focus: return "Focus"
        }
    }

    /// Get the next mode (for swipe left)
    var next: ViewMode {
        switch self {
        case .chapters: return .quality
        case .quality: return .focus
        case .focus: return .chapters
        }
    }

    /// Get the previous mode (for swipe right)
    var previous: ViewMode {
        switch self {
        case .chapters: return .focus
        case .quality: return .chapters
        case .focus: return .quality
        }
    }

    /// Index for dot indicator (0, 1, 2)
    var index: Int {
        switch self {
        case .chapters: return 0
        case .quality: return 1
        case .focus: return 2
        }
    }
}
