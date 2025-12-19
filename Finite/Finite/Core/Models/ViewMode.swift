//
//  ViewMode.swift
//  Finite
//
//  Four lenses for viewing your life grid
//

import Foundation

/// The four view modes for the life grid
/// Each mode shows the same weeks but with different color meanings
/// Order: Chapters → Quality → Focus → Horizons (swipe left cycles through)
enum ViewMode: String, Codable, CaseIterable {
    /// Chapters mode: Weeks colored by life phase (College=indigo, Career=teal, etc.)
    case chapters

    /// Quality mode: Weeks colored by rating spectrum (1-5, red to green)
    case quality

    /// Focus mode: B&W only, mortality confrontation
    case focus

    /// Horizons mode: Future milestones pinned to weeks, past dimmed
    case horizons

    /// Display name for the mode label flash
    var displayName: String {
        switch self {
        case .chapters: return "Chapters"
        case .quality: return "Quality"
        case .focus: return "Focus"
        case .horizons: return "Horizons"
        }
    }

    /// Subheader text to help identify the view mode
    var subheader: String {
        switch self {
        case .chapters: return "Life phases"
        case .quality: return "Week ratings"
        case .focus: return "Mortality"
        case .horizons: return "Future goals"
        }
    }

    /// Get the next mode (for swipe left)
    /// Chapters → Quality → Focus → Horizons → Chapters
    var next: ViewMode {
        switch self {
        case .chapters: return .quality
        case .quality: return .focus
        case .focus: return .horizons
        case .horizons: return .chapters
        }
    }

    /// Get the previous mode (for swipe right)
    /// Chapters ← Quality ← Focus ← Horizons ← Chapters
    var previous: ViewMode {
        switch self {
        case .chapters: return .horizons
        case .quality: return .chapters
        case .focus: return .quality
        case .horizons: return .focus
        }
    }

    /// Index for dot indicator (0, 1, 2, 3)
    var index: Int {
        switch self {
        case .chapters: return 0
        case .quality: return 1
        case .focus: return 2
        case .horizons: return 3
        }
    }

    /// Total number of view modes
    static var count: Int { 4 }
}
