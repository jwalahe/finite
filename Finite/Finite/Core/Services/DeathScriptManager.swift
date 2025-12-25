//
//  DeathScriptManager.swift
//  Finite
//
//  Script library for Death Voice - all utterances organized by trigger type
//  Philosophy: Calm. Patient. Observant. Never judging, always watching.
//

import Foundation

struct DeathScriptManager {

    static func script(for trigger: DeathTrigger) -> String {
        let scripts = scriptsForType(trigger.type, context: trigger.context)
        return scripts.randomElement() ?? "I am watching."
    }

    private static func scriptsForType(
        _ type: DeathTriggerType,
        context: DeathTrigger.Context
    ) -> [String] {
        let name = context.userName

        switch type {
        case .firstMilestoneEver:
            return [
                "Your first horizon. I see you're making plans, \(name).",
                "Ah. You've decided to reach for something. Interesting.",
                "A commitment. The first of many, perhaps.",
                "So it begins. A future, marked.",
                "\(name). You've pinned something to the time you have left. I noticed."
            ]

        case .milestoneCompleted:
            let milestone = context.milestoneName ?? "that goal"
            return [
                "You did it. \(milestone). I noticed.",
                "\(milestone) is yours now. Well done, \(name).",
                "One horizon reached. The time was well spent.",
                "Claimed. That week had meaning.",
                "\(name). You finished \(milestone). I was watching.",
                "Another mark against the empty. You're doing well.",
                "Done. \(milestone) is behind you now."
            ]

        case .milestoneCreated:
            let count = context.milestoneCount ?? 2
            return [
                "Another horizon. You're building a map of your remaining time.",
                "More plans. Good. Empty weeks serve no one.",
                "\(count) horizons now. You're taking this seriously.",
                "The grid fills with intention. I observe.",
                "You continue to mark the future. Most do not.",
                "Noted. Another point on your map of time."
            ]

        case .milestoneDeleted:
            return [
                "Gone. Perhaps it wasn't meant to be.",
                "You've released that one. The future reshapes.",
                "Deleted. I make no judgment. Time remains indifferent.",
                "A horizon removed. The grid simplifies.",
                "That one is no longer marked. I note it.",
                "Released. The future is lighter by one intention."
            ]

        case .milestoneMoved:
            let milestone = context.milestoneName ?? "That horizon"
            if let weeks = context.weeksAway, weeks > 0 {
                // Moved further (postponed)
                return [
                    "Pushed further out. There's always more time. Until there isn't.",
                    "Later, then. I understand. I can wait.",
                    "\(milestone) recedes. Be careful it doesn't disappear entirely.",
                    "Delayed. I have no opinion. Time does not care.",
                    "Further out. You have your reasons.",
                    "Postponed. The weeks remain. The intention wavers."
                ]
            } else {
                // Moved closer (urgency)
                return [
                    "Sooner. You feel the pressure now. Good.",
                    "Moved closer. Perhaps you realize time is shorter than it seems.",
                    "Urgency. It suits you, \(name).",
                    "Closer now. You're paying attention.",
                    "The deadline approaches faster by your choice. Interesting.",
                    "Accelerated. You're taking this seriously."
                ]
            }

        case .milestoneOverdue:
            let milestone = context.milestoneName ?? "A horizon"
            return [
                "\(milestone) has passed. The week is gone.",
                "You missed \(milestone). Time forgives nothing, \(name).",
                "That moment slipped away. I was there. You weren't.",
                "Overdue. The window closed. There may be others.",
                "\(milestone) came and went. I noticed your absence.",
                "The deadline passed. \(milestone) remains unclaimed."
            ]

        case .returnsAfterAbsence:
            let weeks = context.weeksMissed ?? 3
            return [
                "It's been \(weeks) weeks, \(name). I've been here the whole time.",
                "You were away. \(weeks) weeks vanished. Did you notice?",
                "Welcome back. \(weeks) weeks have passed. They won't return.",
                "\(weeks) weeks since we last spoke. The grid grew shorter.",
                "Ah, \(name). \(weeks) weeks. I wondered if you'd return.",
                "Time moved on without you. \(weeks) weeks. I kept count.",
                "\(name). You've returned. \(weeks) weeks passed in your absence."
            ]

        case .noMilestonesExist:
            return [
                "No horizons. The future is a blank page, \(name). Is that intentional?",
                "Nothing planned. Every week the same. Is that enough?",
                "An empty grid. Some find peace in that. Others find nothing.",
                "You've set no horizons. Time will pass regardless.",
                "The future is unmarked. That's your choice to make.",
                "I see no intentions here. Just empty weeks waiting.",
                "A life without markers. Perhaps that's freedom. Perhaps not."
            ]

        case .multipleOverdue:
            return [
                "Three horizons have passed you by now. A pattern emerges.",
                "You set intentions. You let them slip. I'm only observing.",
                "The overdue pile grows. Do these still matter to you?",
                "Three missed. Perhaps the targets were unrealistic. Or perhaps not.",
                "A pattern of delay. I note it without judgment.",
                "Several horizons, all overdue. What does that tell you, \(name)?"
            ]
        }
    }
}
