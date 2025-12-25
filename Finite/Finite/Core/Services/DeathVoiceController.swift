//
//  DeathVoiceController.swift
//  Finite
//
//  State machine for Death Voice triggers, limits, and priority
//  Philosophy: Death speaks rarely. When Death speaks, it matters.
//

import SwiftUI
import Combine

// MARK: - Trigger Types

enum DeathTriggerType: Int, CaseIterable {
    case returnsAfterAbsence = 1
    case milestoneOverdue = 2
    case milestoneCompleted = 3
    case firstMilestoneEver = 4
    case multipleOverdue = 5
    case noMilestonesExist = 6
    case milestoneCreated = 7
    case milestoneMoved = 8
    case milestoneDeleted = 9

    var priority: Int { rawValue }

    var bucket: Bucket {
        switch self {
        case .milestoneCompleted, .firstMilestoneEver,
             .milestoneCreated, .milestoneMoved, .milestoneDeleted:
            return .action
        case .returnsAfterAbsence, .milestoneOverdue,
             .noMilestonesExist, .multipleOverdue:
            return .inaction
        }
    }

    enum Bucket {
        case action
        case inaction
    }
}

// MARK: - Trigger Context

struct DeathTrigger {
    let type: DeathTriggerType
    let context: Context
    let timestamp: Date = Date()

    struct Context {
        var userName: String = "Traveler"
        var milestoneName: String?
        var weeksRemaining: Int?
        var weeksAway: Int?
        var weeksMissed: Int?
        var milestoneCount: Int?
        var overdueCount: Int?
    }
}

// MARK: - Limits Configuration

struct DeathVoiceLimits {
    /// Maximum speeches per session (app open → background)
    static let maxPerSession = 2

    /// Minimum time between speeches (seconds)
    static let cooldownSeconds: TimeInterval = 120

    /// Triggers that ALWAYS speak (ignore session limit)
    static let alwaysSpeakTriggers: Set<DeathTriggerType> = [
        .firstMilestoneEver,
        .milestoneCompleted,
        .returnsAfterAbsence
    ]

    /// Triggers that NEVER speak if another trigger spoke this session
    static let yieldingTriggers: Set<DeathTriggerType> = [
        .milestoneCreated,
        .milestoneMoved,
        .noMilestonesExist
    ]
}

// MARK: - Settings

struct DeathVoiceSettings: Codable {
    var isEnabled: Bool = true
    var frequency: Frequency = .sparse
    var speakAboutAchievements: Bool = true
    var speakAboutMissedMoments: Bool = true
    var speakAboutAbsences: Bool = true

    enum Frequency: String, Codable, CaseIterable {
        case sparse = "sparse"
        case normal = "normal"
        case more = "more"

        var displayName: String {
            switch self {
            case .sparse: return "Sparse"
            case .normal: return "Normal"
            case .more: return "More"
            }
        }

        var description: String {
            switch self {
            case .sparse: return "Only key moments"
            case .normal: return "Standard observations"
            case .more: return "More frequent"
            }
        }
    }
}

// MARK: - Controller

class DeathVoiceController: ObservableObject {
    static let shared = DeathVoiceController()

    @Published private(set) var speechCountThisSession = 0
    @Published private(set) var lastSpokeAt: Date?
    @Published private(set) var isProcessing = false

    private var pendingTriggers: [DeathTrigger] = []
    private var hasSpokenThisViewAppear = false
    private var debounceWorkItem: DispatchWorkItem?

    // Settings
    @AppStorage("deathVoice.isEnabled") var isEnabled: Bool = true
    @AppStorage("deathVoice.frequency") private var frequencyRaw: String = DeathVoiceSettings.Frequency.sparse.rawValue
    @AppStorage("deathVoice.speakAchievements") var speakAboutAchievements: Bool = true
    @AppStorage("deathVoice.speakMissed") var speakAboutMissedMoments: Bool = true
    @AppStorage("deathVoice.speakAbsences") var speakAboutAbsences: Bool = true

    // Tracking for sparse triggers
    @AppStorage("deathVoice.hasSpokenFirstMilestone") private var hasSpokenFirstMilestone: Bool = false
    @AppStorage("deathVoice.lastHorizonsVisit") private var lastHorizonsVisitTimestamp: Double = 0
    @AppStorage("deathVoice.emptyStateVisitCount") private var emptyStateVisitCount: Int = 0

    var frequency: DeathVoiceSettings.Frequency {
        get { DeathVoiceSettings.Frequency(rawValue: frequencyRaw) ?? .sparse }
        set { frequencyRaw = newValue.rawValue }
    }

    var lastHorizonsVisit: Date? {
        get { lastHorizonsVisitTimestamp > 0 ? Date(timeIntervalSince1970: lastHorizonsVisitTimestamp) : nil }
        set { lastHorizonsVisitTimestamp = newValue?.timeIntervalSince1970 ?? 0 }
    }

    private init() {}

    // MARK: - Lifecycle

    func onViewAppear() {
        hasSpokenThisViewAppear = false
    }

    func onAppBecameActive() {
        // Reset session count when app becomes active from background
        speechCountThisSession = 0
    }

    // MARK: - Event Handling

    func onEvent(_ trigger: DeathTrigger) {
        guard isEnabled else { return }
        guard shouldTriggerForCategory(trigger.type) else { return }
        guard shouldTriggerForFrequency(trigger.type) else { return }

        // Collect trigger
        pendingTriggers.append(trigger)

        // Debounce - process after settling (allows multiple rapid events to consolidate)
        debounceWorkItem?.cancel()
        let workItem = DispatchWorkItem { [weak self] in
            self?.processTriggers()
        }
        debounceWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: workItem)
    }

    private func processTriggers() {
        guard !pendingTriggers.isEmpty else { return }

        // Sort by priority (lower number = higher priority)
        let sorted = pendingTriggers.sorted { $0.type.priority < $1.type.priority }
        guard let highest = sorted.first else {
            pendingTriggers.removeAll()
            return
        }

        // Check limits
        if !canSpeak(trigger: highest) {
            pendingTriggers.removeAll()
            return
        }

        // Speak
        isProcessing = true
        speak(highest)

        // Update state
        speechCountThisSession += 1
        lastSpokeAt = Date()
        hasSpokenThisViewAppear = true
        pendingTriggers.removeAll()

        // Mark first milestone as spoken
        if highest.type == .firstMilestoneEver {
            hasSpokenFirstMilestone = true
        }
    }

    private func canSpeak(trigger: DeathTrigger) -> Bool {
        // Always-speak triggers bypass limits
        if DeathVoiceLimits.alwaysSpeakTriggers.contains(trigger.type) {
            return true
        }

        // Check session limit
        if speechCountThisSession >= DeathVoiceLimits.maxPerSession {
            return false
        }

        // Check cooldown
        if let last = lastSpokeAt,
           Date().timeIntervalSince(last) < DeathVoiceLimits.cooldownSeconds {
            return false
        }

        // Check if yielding trigger and already spoke this view appear
        if DeathVoiceLimits.yieldingTriggers.contains(trigger.type) &&
           hasSpokenThisViewAppear {
            return false
        }

        return true
    }

    private func speak(_ trigger: DeathTrigger) {
        let script = DeathScriptManager.script(for: trigger)
        MortalityVoice.shared.speak(script) { [weak self] in
            DispatchQueue.main.async {
                self?.isProcessing = false
            }
        }
    }

    // MARK: - Category Filtering

    private func shouldTriggerForCategory(_ type: DeathTriggerType) -> Bool {
        switch type.bucket {
        case .action:
            return speakAboutAchievements
        case .inaction:
            switch type {
            case .returnsAfterAbsence:
                return speakAboutAbsences
            case .milestoneOverdue, .multipleOverdue:
                return speakAboutMissedMoments
            case .noMilestonesExist:
                return speakAboutMissedMoments
            default:
                return true
            }
        }
    }

    // MARK: - Frequency Filtering

    private func shouldTriggerForFrequency(_ type: DeathTriggerType) -> Bool {
        switch frequency {
        case .sparse:
            // Only completions, first milestone, overdue, returns
            return [.milestoneCompleted, .firstMilestoneEver,
                    .milestoneOverdue, .returnsAfterAbsence].contains(type)
        case .normal:
            // Above + creates (sparse), empty state
            return type != .milestoneMoved && type != .milestoneDeleted
        case .more:
            // Everything
            return true
        }
    }

    // MARK: - Sparse Milestone Creation Logic

    func shouldSpeakForMilestoneCount(_ count: Int) -> Bool {
        // Speak on 3rd, 5th, 10th, then every 10th
        let speakAt = [3, 5, 10, 20, 30, 40, 50]
        return speakAt.contains(count) || (count > 50 && count % 25 == 0)
    }

    func shouldSpeakForEmptyState() -> Bool {
        emptyStateVisitCount += 1
        if emptyStateVisitCount == 1 { return true }
        return emptyStateVisitCount % 3 == 0
    }

    // MARK: - Horizons Visit Tracking

    func updateHorizonsVisit() {
        lastHorizonsVisit = Date()
    }

    func weeksSinceLastVisit() -> Int? {
        guard let lastVisit = lastHorizonsVisit else { return nil }
        let components = Calendar.current.dateComponents([.weekOfYear], from: lastVisit, to: Date())
        return components.weekOfYear
    }
}
