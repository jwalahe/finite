//
//  ViewMode.swift
//  Finite
//
//  Three lenses for viewing your life grid
//

import Foundation

/// The three view modes for the life grid
/// Each mode shows the same weeks but with different color meanings
/// Order: Focus (default) → Chapters → Quality
enum ViewMode: String, Codable, CaseIterable {
    /// Focus mode: B&W only, mortality confrontation (default view)
    case focus

    /// Chapters mode: Weeks colored by life phase (College=indigo, Career=teal, etc.)
    case chapters

    /// Quality mode: Weeks colored by rating spectrum (1-5, red to green)
    case quality

    /// Display name for the mode label flash
    var displayName: String {
        switch self {
        case .focus: return "Focus"
        case .chapters: return "Chapters"
        case .quality: return "Quality"
        }
    }

    /// Subheader text to help identify the view mode
    var subheader: String {
        switch self {
        case .focus: return "Mortality"
        case .chapters: return "Life phases"
        case .quality: return "Week ratings"
        }
    }

    /// Get the next mode (for swipe left)
    /// Focus → Chapters → Quality → Focus
    var next: ViewMode {
        switch self {
        case .focus: return .chapters
        case .chapters: return .quality
        case .quality: return .focus
        }
    }

    /// Get the previous mode (for swipe right)
    /// Focus ← Chapters ← Quality ← Focus
    var previous: ViewMode {
        switch self {
        case .focus: return .quality
        case .chapters: return .focus
        case .quality: return .chapters
        }
    }

    /// Index for dot indicator (0, 1, 2)
    var index: Int {
        switch self {
        case .focus: return 0
        case .chapters: return 1
        case .quality: return 2
        }
    }
}
