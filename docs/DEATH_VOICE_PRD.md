# Finite: Death Voice Feature
## Complete Product Specification — The Observer

> **Version:** 1.0  
> **Status:** Design Complete — Ready for Implementation  
> **Last Updated:** December 2025  
> **Scope:** Horizons View (extensible to full app)  
> **Philosophy:** Death is not your enemy. Death is your witness.

---

# Part I: Psychological Foundation

---

## 1. Core Psychology: Why This Works

### 1.1 The Research Foundation

This feature is grounded in five established psychological frameworks:

| Framework | Source | Core Insight | Application to Death Voice |
|-----------|--------|--------------|---------------------------|
| **Anthropomorphism Theory** | Epley, Waytz & Cacioppo (2007) | Humans personify agents to understand unpredictable forces | Death as persona makes mortality comprehensible |
| **Terror Management Theory** | Greenberg, Pyszczynski & Solomon | Mortality awareness triggers behavior change | Voice channels anxiety into constructive action |
| **Protection Motivation Theory** | Rogers (1975, 1983) | Fear + efficacy = behavior change | Death speaks; milestones provide efficacy |
| **Accountability Psychology** | Self-Determination Theory | Being observed increases follow-through | Death as silent witness creates accountability |
| **Memento Mori Tradition** | Stoic Philosophy | Death awareness creates urgency and meaning | Voice is the modern "slave behind the general" |

### 1.2 Anthropomorphism: Making the Abstract Tangible

**Research:** Epley, Waytz & Cacioppo identified three motivations for anthropomorphism:

1. **Effectance Motivation** — The need to understand and predict unpredictable forces
2. **Sociality Motivation** — The need for social connection (even with non-human agents)
3. **Elicited Agent Knowledge** — Using human mental models to interpret non-human behavior

**Key Finding:** "Anthropomorphizing makes things appear more predictable and understandable, suggesting that anthropomorphism satisfies effectance motivation." (Waytz et al., 2010)

**Application:** Death is the ultimate unpredictable force. By giving it a voice — a persona — we make it comprehensible. Users don't anthropomorphize death to befriend it; they do so to *understand* it, to feel some sense of relationship with the inevitable.

**Critical Insight:** Individual differences matter. Research shows lonely people and those with high "need for closure" anthropomorphize more readily. Finite's 29+ demographic — often confronting mortality through aging parents, career transitions, or relationship changes — may be particularly receptive to this personification.

### 1.3 Terror Management Theory: Channeling Mortality Awareness

**Research:** Terror Management Theory (TMT) demonstrates that mortality salience (awareness of death) triggers psychological defense mechanisms:

- **Proximal defenses:** Immediate coping (denial, distraction)
- **Distal defenses:** Pursuing meaning, self-esteem enhancement, worldview defense

**Key Finding:** "Mortality salience increases prosocial behavior, goal pursuit, and self-regulation when channeled properly." (PLOS One, 2021)

**The Problem with WeCroak:** Apps like WeCroak trigger mortality salience without providing a constructive outlet. They create anxiety without resolution.

**Application:** Finite's Death Voice triggers mortality salience, but the app itself IS the constructive outlet:
- Voice speaks → anxiety triggered
- User sees grid → visual representation of time
- User sets/completes milestone → anxiety channeled into intentional action

**Critical Design Principle:** Death must never speak without the user having immediate access to constructive action (rating, milestone creation, completion). The voice creates the tension; the app resolves it.

### 1.4 Protection Motivation Theory: Fear + Efficacy

**Research:** Rogers (1975, 1983) identified four components of effective fear appeals:

1. **Perceived Severity** — How bad is the threat?
2. **Perceived Vulnerability** — How likely am I to be affected?
3. **Response Efficacy** — Will the recommended action work?
4. **Self-Efficacy** — Can I actually do it?

**Key Finding:** Fear appeals only work when paired with high self-efficacy. Without it, people become *hyperdefensive* — they deny the threat rather than address it.

**Application:**

| PMT Component | Death Voice Implementation |
|---------------|---------------------------|
| Perceived Severity | Death's voice itself conveys gravity |
| Perceived Vulnerability | Personalized: "You have X weeks remaining" |
| Response Efficacy | Milestones = actionable responses to mortality |
| Self-Efficacy | Simple actions (tap to set, tap to complete) |

**Critical Design Principle:** Death must never create fear without the user having a clear, achievable action available. The milestone system provides response efficacy; the simple UI provides self-efficacy.

### 1.5 Accountability: The Observer Effect

**Research:** Accountability psychology shows that being observed changes behavior:

- **Public self-awareness** increases prosocial behavior (van Bommel et al., 2012)
- **Accountability cues** (cameras, names displayed) reverse the bystander effect
- **Autonomous accountability** (internal desire to please) outperforms controlled accountability (external pressure) for long-term change

**Key Finding:** "The accountability inherent in the expectation of a social interaction affects patients' motivation to adhere to treatment." (PMC, 2017)

**Application:** Death as persona creates a persistent observer. Not a judge — an observer. The user knows Death "notices" what they do and don't do. This creates:

- **Accountability without judgment** — Death doesn't criticize; it observes
- **Autonomous motivation** — Users choose to engage; nothing is forced
- **Witness effect** — Actions have weight because someone is watching

**Critical Design Principle:** Death never punishes or shames. Death simply *notices*. This distinction is crucial for autonomous accountability.

### 1.6 Memento Mori: The Stoic Tradition

**Historical Context:** In Roman triumphs, a slave would whisper to the victorious general: "Memento mori" — remember you must die. This wasn't meant to depress but to *ground*.

**Stoic Philosophy:**
- Marcus Aurelius: "You could leave life right now. Let that determine what you do and say and think."
- Seneca: "Let us prepare our minds as if we'd come to the very end of life. Let us postpone nothing."
- Epictetus: "Keep death and exile before your eyes each day... by doing so, you'll never have a base thought."

**Key Insight:** The Stoics found this thought *invigorating*, not depressing. It created urgency and clarity.

**Application:** Death's voice in Finite is the modern equivalent of the slave behind the general. It whispers not to depress but to *orient*. Every interaction is a reminder that time is finite — and therefore valuable.

**Critical Design Principle:** Death's tone is never morbid. It is calm, patient, even gentle. The gravity comes from the truth it speaks, not from dramatic delivery.

---

## 2. Persona Definition: Who is Death?

### 2.1 Character Archetype

Death in Finite is **The Observer** — not antagonist, not ally, but witness.

| Attribute | Expression |
|-----------|------------|
| **Patient** | Never rushed. Slow, deliberate speech. "I can wait." |
| **Observant** | Notices what you do AND what you don't do. "I see you." |
| **Neutral** | Not judging. Not celebrating. Just... noting. |
| **Inevitable** | Doesn't threaten. Doesn't need to. The fact is enough. |
| **Honest** | No false comfort. No exaggeration. Just truth. |
| **Occasionally present** | Speaks rarely. When Death speaks, it matters. |

### 2.2 What Death is NOT

Understanding what Death is *not* is as important as what it is:

| Anti-Pattern | Why It Fails |
|--------------|--------------|
| **Coach** ("You can do it!") | Patronizing. Undermines gravity. |
| **Critic** ("You failed again") | Creates shame. Triggers hyperdefensiveness. |
| **Nag** ("Don't forget!") | Annoying. Users will disable. |
| **Game master** ("Achievement unlocked!") | Gamification destroys authenticity. |
| **Sarcastic companion** ("Oh, you're back?") | Undermines seriousness. |
| **Therapist** ("How does that make you feel?") | Wrong relationship. Death doesn't care about feelings. |

### 2.3 Voice Character

**Tone:** Calm. Almost gentle. This is what makes it unsettling — and profound.

**Pacing:** Slow. Deliberate. Every word lands.

**Register:** Formal but not archaic. Timeless.

**Relationship to User:** Death knows your name. Death has been waiting. Death will be there at the end. But Death is not rushing.

### 2.4 Psychological Safety

Death's presence must feel **safe enough to engage with**. This requires:

1. **User Control** — Voice can be disabled entirely
2. **Predictability** — Users learn when Death speaks (patterns emerge)
3. **Constructive Outlet** — Every utterance pairs with actionable UI
4. **No Punishment** — Death never withholds features or creates negative consequences
5. **Exit Available** — User can always leave Horizons view

---

## 3. The Two Buckets: Action & Inaction

Death speaks in response to two categories of user behavior:

### 3.1 Bucket A: User Takes Action

When the user actively engages with their future — setting intentions, achieving goals, making choices — Death bears witness.

**Psychology:** This is **positive reinforcement through acknowledgment**. Not praise (which would be patronizing), but recognition. The user's actions have weight because they are observed.

**Triggers:**
- First milestone ever created
- Milestone created (subsequent, sparse)
- Milestone completed
- Milestone deleted
- Milestone moved (further or closer)

### 3.2 Bucket B: User Doesn't Take Action

When the user avoids, forgets, or drifts — when time passes without intention — Death notices.

**Psychology:** This is **accountability through observation**. Not punishment, but awareness. The user cannot pretend time isn't passing because Death is counting.

**Triggers:**
- Milestone becomes overdue
- User returns after long absence
- No milestones exist
- Approaching milestone (user absent)
- Multiple overdue milestones (pattern)

### 3.3 The Balance

Both buckets are essential:

| Bucket | Purpose | Emotional Register |
|--------|---------|-------------------|
| Action | Recognition, witness, weight | Calm acknowledgment |
| Inaction | Accountability, awareness, truth | Gentle observation |

**Critical Balance:** Death should speak roughly equally about both. If Death only speaks about inaction, it becomes a nag. If Death only speaks about action, it becomes hollow praise.

---

# Part II: Feature Specification

---

## 4. Trigger Catalog: Bucket A (Action)

### 4.1 A1: First Milestone Ever Created

**Trigger:** User creates their very first milestone in the app.

**Frequency:** Once, ever. This is a significant moment.

**Psychology:** The user's first act of intention against mortality. A commitment to the future. Death acknowledges this threshold crossing.

**Timing:** 1.5 seconds after builder sheet dismisses, as marker appears on grid.

**Scripts:**
```
"Your first horizon. I see you're making plans, {name}."

"Ah. You've decided to reach for something. Interesting."

"A commitment. The first of many, perhaps."

"So it begins. A future, marked."

"{name}. You've pinned something to the time you have left. I noticed."
```

**Voice Parameters:**
```swift
pitch: 0.7
rate: 0.4
preUtteranceDelay: 1.5
```

**Haptic:** None. Voice only. Silence is the haptic.

---

### 4.2 A2: Milestone Created (Subsequent)

**Trigger:** User creates 2nd, 3rd, nth milestone.

**Frequency:** Sparse — speak on 3rd, 5th, 10th, then every 10th milestone.

**Psychology:** Occasional acknowledgment of continued intention. Reinforces pattern of planning without becoming expected or stale.

**Timing:** 1 second after creation.

**Scripts:**
```
"Another horizon. You're building a map of your remaining time."

"More plans. Good. Empty weeks serve no one."

"{count} horizons now. You're taking this seriously."

"The grid fills with intention. I observe."

"You continue to mark the future. Most do not."
```

**Sparse Logic:**
```swift
func shouldSpeakForMilestoneCount(_ count: Int) -> Bool {
    let speakAt = [3, 5, 10, 20, 30, 40, 50]
    return speakAt.contains(count) || (count > 50 && count % 25 == 0)
}
```

---

### 4.3 A3: Milestone Completed

**Trigger:** User marks a milestone as complete.

**Frequency:** Every time. Completion is rare and meaningful.

**Psychology:** Recognition. Not celebration — recognition. The user claimed something from time. Death witnessed.

**Timing:** 2 seconds after completion animation finishes. Let the visual moment land first.

**Scripts:**
```
"You did it. {milestoneName}. I noticed."

"{milestoneName} is yours now. Well done, {name}."

"One horizon reached. The time was well spent."

"Claimed. That week had meaning."

"{name}. You finished {milestoneName}. I was watching."

"Another mark against the empty. You're doing well."
```

**Haptic:** None during voice. The completion animation already had haptic.

---

### 4.4 A4: Milestone Deleted

**Trigger:** User deletes a milestone (from builder in edit mode).

**Frequency:** Every time. Letting go is significant.

**Psychology:** Not judgment. Observation. Some things are released. That's a choice too.

**Timing:** Immediately after deletion confirms.

**Scripts:**
```
"Gone. Perhaps it wasn't meant to be."

"You've released that one. The future reshapes."

"Deleted. I make no judgment. Time remains indifferent."

"A horizon removed. The grid simplifies."

"That one is no longer marked. I note it."
```

---

### 4.5 A5: Milestone Moved Further (Postponed)

**Trigger:** User edits a milestone to push the target week later.

**Frequency:** Sparse — only if moved by 8+ weeks. Small adjustments don't warrant comment.

**Psychology:** Gentle observation. Not accusation. Postponement is a choice. Death has infinite patience.

**Scripts:**
```
"Pushed further out. There's always more time. Until there isn't."

"Later, then. I understand. I can wait."

"The horizon recedes. Be careful it doesn't disappear entirely."

"Delayed. I have no opinion. Time does not care."

"Further out. You have your reasons."
```

---

### 4.6 A6: Milestone Moved Closer (Urgency)

**Trigger:** User edits a milestone to pull the target week closer (by 4+ weeks).

**Frequency:** Every time this threshold is crossed.

**Psychology:** Recognition of decisiveness. The user feels urgency. Death acknowledges.

**Scripts:**
```
"Sooner. You feel the pressure now. Good."

"Moved closer. Perhaps you realize time is shorter than it seems."

"Urgency. It suits you, {name}."

"Closer now. You're paying attention."

"The deadline approaches faster by your choice. Interesting."
```

---

## 5. Trigger Catalog: Bucket B (Inaction)

### 5.1 B1: Milestone Becomes Overdue

**Trigger:** A milestone's target week passes without completion.

**Frequency:** Once per milestone, when it first becomes overdue.

**When:** Next time user opens Horizons view after the deadline passed.

**Psychology:** The moment is gone. Death was there. The user wasn't. Not punishment — just fact.

**Scripts:**
```
"{milestoneName} has passed. The week is gone."

"You missed {milestoneName}. Time forgives nothing, {name}."

"That moment slipped away. I was there. You weren't."

"Overdue. The window closed. There may be others."

"{milestoneName} came and went. I noticed your absence."
```

**Timing:** 2 seconds after Horizons view loads.

**Priority Logic:** Only speak about ONE overdue milestone per session. If multiple are overdue, pick the most recently overdue.

---

### 5.2 B2: Returns After Long Absence

**Trigger:** User opens Horizons view for the first time in 3+ weeks.

**Frequency:** Once per return.

**Psychology:** Time passed. The user wasn't watching. Death was counting.

**Scripts:**
```
"It's been {weeks} weeks, {name}. I've been here the whole time."

"You were away. {weeks} weeks vanished. Did you notice?"

"Welcome back. {weeks} weeks have passed. They won't return."

"{weeks} weeks since we last spoke. The grid grew shorter."

"Ah, {name}. {weeks} weeks. I wondered if you'd return."

"Time moved on without you. {weeks} weeks. I kept count."
```

**Timing:** Immediately on view appear, after 1 second delay.

---

### 5.3 B3: No Milestones Exist (Empty Horizons)

**Trigger:** User opens Horizons view but has zero milestones.

**Frequency:** 
- First time ever: Speak
- Subsequent: Only every 3rd visit with no milestones

**Psychology:** Aimlessness. Not wrong, but noticeable. Some find peace in an empty grid. Others find nothing.

**Scripts:**
```
"No horizons. The future is a blank page, {name}. Is that intentional?"

"Nothing planned. Every week the same as the last. Is that enough for you?"

"An empty grid. Some find peace in that. Others find nothing."

"You've set no horizons. Time will pass regardless."

"The future is unmarked. That's your choice to make."

"I see no intentions here. Just empty weeks waiting."
```

**Frequency Logic:**
```swift
func shouldSpeakForEmptyState(visitCount: Int) -> Bool {
    if visitCount == 1 { return true }
    return visitCount % 3 == 0
}
```

---

### 5.4 B4: Milestone Approaching (But User Absent)

**Trigger:** A milestone is within 2 weeks, and user hasn't opened the app in 7+ days.

**Delivery:** This triggers a **local notification**, not in-app speech.

**Frequency:** Once per milestone.

**Notification:**
```
Title: "{milestoneName}"
Body: "2 weeks remain. — Death"
```

**If user opens app from notification:**

Death speaks when Horizons loads:
```
"Ah, you came. {milestoneName} awaits. {weeks} weeks."

"The notification reached you. {milestoneName} draws near."

"Good. You're here. {milestoneName} in {weeks} weeks."
```

---

### 5.5 B5: Multiple Overdue Milestones (Pattern)

**Trigger:** User has 3+ overdue milestones.

**Frequency:** Once, when the 3rd milestone becomes overdue.

**Psychology:** Pattern recognition. Not lecture — observation. A trend has emerged.

**Scripts:**
```
"Three horizons have passed you by now. A pattern emerges."

"You set intentions. You let them slip. I'm only observing."

"The overdue pile grows. Do these still matter to you?"

"Three missed. Perhaps the targets were unrealistic. Or perhaps not."

"A pattern of delay. I note it without judgment."
```

---

## 6. Frequency & Fatigue Prevention

### 6.1 The Core Problem

If Death speaks too often, it becomes:
- Annoying (users disable)
- Expected (loses impact)
- Background noise (ignored)

If Death speaks too rarely, it becomes:
- Forgotten (no relationship forms)
- Jarring (unexpected = startling)
- Disconnected (no narrative continuity)

### 6.2 Global Limits

```swift
struct DeathVoiceLimits {
    /// Maximum speeches per session (app open → background)
    static let maxPerSession = 2
    
    /// Minimum time between speeches (seconds)
    static let cooldownSeconds: TimeInterval = 120
    
    /// Triggers that ALWAYS speak (ignore session limit)
    static let alwaysSpeakTriggers: Set<DeathTriggerType> = [
        .firstMilestoneEver,
        .milestoneCompleted,
        .returnsAfterLongAbsence
    ]
    
    /// Triggers that NEVER speak if another trigger spoke this session
    static let yieldingTriggers: Set<DeathTriggerType> = [
        .milestoneCreated,
        .milestoneMoved,
        .noMilestonesExist
    ]
}
```

### 6.3 Priority System

When multiple triggers could fire, pick highest priority:

| Priority | Trigger | Rationale |
|----------|---------|-----------|
| 1 (highest) | Returns after absence | Orientation is most important |
| 2 | Milestone became overdue | Time-sensitive truth |
| 3 | Milestone completed | Rare, meaningful action |
| 4 | First milestone ever | Once in a lifetime |
| 5 | Multiple overdue (pattern) | Important but not urgent |
| 6 | No milestones exist | Observation, not urgent |
| 7 | Milestone created | Acknowledgment |
| 8 (lowest) | Milestone moved | Least significant |

### 6.4 Session State Machine

```swift
class DeathVoiceController: ObservableObject {
    @Published private(set) var speechCountThisSession = 0
    @Published private(set) var lastSpokeAt: Date?
    
    private var pendingTriggers: [DeathTrigger] = []
    private var hasSpokenThisViewAppear = false
    
    func onViewAppear() {
        hasSpokenThisViewAppear = false
    }
    
    func onEvent(_ trigger: DeathTrigger) {
        // Collect trigger
        pendingTriggers.append(trigger)
        
        // Debounce — process after settling
        debounceAndProcess()
    }
    
    private func debounceAndProcess() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.processTriggers()
        }
    }
    
    private func processTriggers() {
        // Sort by priority
        let sorted = pendingTriggers.sorted { $0.type.priority < $1.type.priority }
        guard let highest = sorted.first else { return }
        
        // Check limits
        if !canSpeak(trigger: highest) {
            pendingTriggers.removeAll()
            return
        }
        
        // Speak
        speak(highest)
        
        // Update state
        speechCountThisSession += 1
        lastSpokeAt = Date()
        hasSpokenThisViewAppear = true
        pendingTriggers.removeAll()
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
}
```

### 6.5 Expected Frequency

Given these limits, typical user experience:

| User Pattern | Speeches Per Week |
|--------------|-------------------|
| Daily user, active | 2-4 speeches |
| Weekly user, active | 1-2 speeches |
| Weekly user, passive | 1 speech (return acknowledgment) |
| Monthly user | 1 speech per visit (absence noted) |

This feels **rare enough to matter**, but **consistent enough to form a relationship**.

---

## 7. User Control & Settings

### 7.1 Philosophy

Death Voice is **opt-out, not opt-in**. It's part of the core experience. But users must have complete control.

**Why opt-out:** If opt-in, most users never try it and miss the signature experience. The feature needs to prove itself.

**Why complete control:** Some users will find it uncomfortable, triggering, or simply annoying. They must be able to disable it without friction.

### 7.2 Settings UI

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│  THE OBSERVER                                               │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Enable Voice                                [ON]  │   │
│  │  A presence speaks in Horizons view                 │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Voice Frequency                                            │
│  ┌────────────────────────────────────────────────────┐   │
│  │ ○ Sparse    ● Normal    ○ More                     │   │
│  │   Only key moments                                  │   │
│  └────────────────────────────────────────────────────┘   │
│                                                             │
│  Speak About                                                │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ [✓] Achievements     When I complete things        │   │
│  │ [✓] Missed moments   When deadlines pass           │   │
│  │ [✓] Absences         When I've been away           │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │             [▶] Hear a preview                       │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 7.3 Frequency Modes

| Mode | Triggers Active | Experience |
|------|-----------------|------------|
| **Sparse** | completions, first milestone, overdue, returns | ~1 speech per week |
| **Normal** | Above + creates (sparse), empty state | ~2-3 speeches per week |
| **More** | Above + every create, moved milestones | ~4-6 speeches per week |

**Default:** Sparse. Let users opt into more intensity.

### 7.4 Category Toggles

Users can disable specific categories:

- **Achievements:** Completions, creations
- **Missed moments:** Overdue milestones
- **Absences:** Return acknowledgments

**Default:** All enabled.

### 7.5 Settings Model

```swift
struct DeathVoiceSettings: Codable {
    var isEnabled: Bool = true
    var frequency: Frequency = .sparse
    var speakAboutAchievements: Bool = true
    var speakAboutMissedMoments: Bool = true
    var speakAboutAbsences: Bool = true
    
    enum Frequency: String, Codable {
        case sparse
        case normal
        case more
    }
}
```

---

## 8. Technical Implementation

### 8.1 Voice Synthesis

```swift
import AVFoundation

class MortalityVoice: NSObject {
    static let shared = MortalityVoice()
    
    private let synthesizer = AVSpeechSynthesizer()
    private var currentUtterance: AVSpeechUtterance?
    
    // Voice parameters for Death persona
    private struct DeathPersona {
        static let pitch: Float = 0.70         // Deep
        static let rate: Float = 0.42          // Slow, deliberate
        static let volume: Float = 0.90        // Clear but not jarring
        static let preDelay: TimeInterval = 0.8
        static let postDelay: TimeInterval = 0.5
    }
    
    override init() {
        super.init()
        synthesizer.delegate = self
        configureAudioSession()
    }
    
    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                options: [.mixWithOthers, .duckOthers]
            )
        } catch {
            print("Audio session configuration failed: \(error)")
        }
    }
    
    func speak(_ text: String, completion: (() -> Void)? = nil) {
        // Stop any current speech
        synthesizer.stopSpeaking(at: .immediate)
        
        // Activate audio session
        try? AVAudioSession.sharedInstance().setActive(true)
        
        // Create utterance
        let utterance = AVSpeechUtterance(string: text)
        utterance.pitchMultiplier = DeathPersona.pitch
        utterance.rate = DeathPersona.rate
        utterance.volume = DeathPersona.volume
        utterance.preUtteranceDelay = DeathPersona.preDelay
        utterance.postUtteranceDelay = DeathPersona.postDelay
        
        // Select best available voice
        utterance.voice = selectVoice()
        
        currentUtterance = utterance
        synthesizer.speak(utterance)
    }
    
    private func selectVoice() -> AVSpeechSynthesisVoice? {
        // Priority order for "Death" voice
        let preferredIdentifiers = [
            "com.apple.voice.enhanced.en-US.Aaron",
            "com.apple.voice.enhanced.en-GB.Daniel",
            "com.apple.voice.premium.en-US.Aaron",
            "com.apple.voice.enhanced.en-US.Tom",
            "com.apple.voice.compact.en-US.Aaron"
        ]
        
        let available = AVSpeechSynthesisVoice.speechVoices()
        
        for identifier in preferredIdentifiers {
            if let voice = available.first(where: { $0.identifier == identifier }) {
                return voice
            }
        }
        
        // Fallback to default English
        return AVSpeechSynthesisVoice(language: "en-US")
    }
    
    func stop() {
        synthesizer.stopSpeaking(at: .word)
    }
}

extension MortalityVoice: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, 
                          didFinish utterance: AVSpeechUtterance) {
        try? AVAudioSession.sharedInstance().setActive(
            false, 
            options: .notifyOthersOnDeactivation
        )
    }
}
```

### 8.2 Trigger System

```swift
enum DeathTriggerType: Int, CaseIterable {
    case returnsAfterAbsence = 1
    case milestoneOverdue = 2
    case milestoneCompleted = 3
    case firstMilestoneEver = 4
    case multipleOverdue = 5
    case noMilestonesExist = 6
    case milestoneCreated = 7
    case milestoneMoved = 8
    
    var priority: Int { rawValue }
    
    var bucket: Bucket {
        switch self {
        case .milestoneCompleted, .firstMilestoneEver, 
             .milestoneCreated, .milestoneMoved:
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
```

### 8.3 Script Manager

```swift
struct DeathScriptManager {
    
    static func script(for trigger: DeathTrigger) -> String {
        let scripts = scriptsForType(trigger.type, context: trigger.context)
        return scripts.randomElement() ?? ""
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
                "So it begins. A future, marked."
            ]
            
        case .milestoneCompleted:
            let milestone = context.milestoneName ?? "that goal"
            return [
                "You did it. \(milestone). I noticed.",
                "\(milestone) is yours now. Well done, \(name).",
                "One horizon reached. The time was well spent.",
                "Claimed. That week had meaning."
            ]
            
        case .milestoneOverdue:
            let milestone = context.milestoneName ?? "A horizon"
            return [
                "\(milestone) has passed. The week is gone.",
                "You missed \(milestone). Time forgives nothing, \(name).",
                "That moment slipped away. I was there. You weren't.",
                "Overdue. The window closed. There may be others."
            ]
            
        case .returnsAfterAbsence:
            let weeks = context.weeksMissed ?? 3
            return [
                "It's been \(weeks) weeks, \(name). I've been here the whole time.",
                "You were away. \(weeks) weeks vanished. Did you notice?",
                "Welcome back. \(weeks) weeks have passed. They won't return.",
                "\(weeks) weeks since we last spoke. The grid grew shorter."
            ]
            
        case .noMilestonesExist:
            return [
                "No horizons. The future is a blank page, \(name). Is that intentional?",
                "Nothing planned. Every week the same. Is that enough?",
                "An empty grid. Some find peace in that. Others find nothing.",
                "You've set no horizons. Time will pass regardless."
            ]
            
        case .milestoneCreated:
            let count = context.milestoneCount ?? 2
            return [
                "Another horizon. You're building a map of your time.",
                "More plans. Good. Empty weeks serve no one.",
                "\(count) horizons now. You're taking this seriously."
            ]
            
        case .milestoneMoved:
            let milestone = context.milestoneName ?? "That horizon"
            if let weeks = context.weeksAway, weeks > 0 {
                return [
                    "Pushed further. There's always more time. Until there isn't.",
                    "Later, then. I understand. I can wait.",
                    "\(milestone) recedes. Be careful it doesn't disappear."
                ]
            } else {
                return [
                    "Sooner. You feel the pressure now. Good.",
                    "Moved closer. Perhaps you realize time is short.",
                    "Urgency. It suits you, \(name)."
                ]
            }
            
        case .multipleOverdue:
            return [
                "Three horizons have passed you by now. A pattern emerges.",
                "You set intentions. You let them slip. I'm only observing.",
                "The overdue pile grows. Do these still matter to you?"
            ]
        }
    }
}
```

### 8.4 Horizons View Integration

```swift
struct HorizonsView: View {
    @StateObject private var voiceController = DeathVoiceController.shared
    @AppStorage("deathVoiceEnabled") private var voiceEnabled = true
    
    @Query(sort: \Milestone.targetWeekNumber) 
    private var milestones: [Milestone]
    
    let currentWeekNumber: Int
    let userName: String
    
    var body: some View {
        ZStack {
            // Grid content
            HorizonsGridView(milestones: milestones)
            
            // Context bar
            MilestoneContextBar(milestones: milestones)
        }
        .onAppear {
            voiceController.onViewAppear()
            checkTriggers()
        }
    }
    
    private func checkTriggers() {
        guard voiceEnabled else { return }
        
        // Check for return after absence
        if let lastVisit = UserDefaults.standard.object(forKey: "lastHorizonsVisit") as? Date {
            let weeksSince = Calendar.current.dateComponents(
                [.weekOfYear], 
                from: lastVisit, 
                to: Date()
            ).weekOfYear ?? 0
            
            if weeksSince >= 3 {
                voiceController.onEvent(DeathTrigger(
                    type: .returnsAfterAbsence,
                    context: .init(userName: userName, weeksMissed: weeksSince)
                ))
            }
        }
        
        // Check for overdue milestones
        let overdue = milestones.filter { 
            !$0.isCompleted && $0.targetWeekNumber < currentWeekNumber 
        }
        
        if let mostRecent = overdue.last, 
           !hasAnnouncedOverdue(mostRecent) {
            voiceController.onEvent(DeathTrigger(
                type: .milestoneOverdue,
                context: .init(userName: userName, milestoneName: mostRecent.name)
            ))
            markAnnouncedOverdue(mostRecent)
        }
        
        // Check for empty state
        if milestones.isEmpty {
            voiceController.onEvent(DeathTrigger(
                type: .noMilestonesExist,
                context: .init(userName: userName)
            ))
        }
        
        // Update last visit
        UserDefaults.standard.set(Date(), forKey: "lastHorizonsVisit")
    }
}
```

### 8.5 Compatibility

| iOS Version | iPhone Model | Support |
|-------------|--------------|---------|
| iOS 16+ | iPhone 14+ | Full support |
| iOS 16+ | iPhone 13 | Full support |
| iOS 15 | Any | Fallback to compact voices |
| iOS 14 | Any | Basic AVSpeechSynthesizer only |

**Minimum Target:** iOS 16, iPhone 14 (as specified in requirements)

---

# Part III: UI Design Guidance

---

## 9. Visual Design System

### 9.1 Death's Presence: Visual Indicators

When Death is about to speak, the UI should subtly acknowledge this:

**Pre-Speech (500ms before):**
- Screen dims very slightly (2-3% darker)
- Subtle vignette appears at edges
- Breathing aura pauses

**During Speech:**
- Dim maintains
- Current week pulse slows
- No other animations

**Post-Speech (fade over 1s):**
- Dim lifts
- Breathing aura resumes
- Normal animations return

### 9.2 Settings UI: The Observer Section

The settings for Death Voice should feel **different** from standard settings:

```
Visual Treatment:
- Section title: "THE OBSERVER" (all caps, letter-spaced)
- Subtitle: "A presence that notices" (italic, secondary)
- Background: Slightly darker than other sections
- Divider: Subtle gradient fade, not hard line

Typography:
- Title: 13pt, semibold, tracking: 2pt
- Labels: 15pt, regular
- Descriptions: 13pt, secondary color, italic

Interactive:
- Toggle: Standard iOS, but with custom track color (deep purple/gray)
- Segmented control for frequency: Custom style with depth
- Preview button: Prominent, centered
```

### 9.3 Visual Language

| Element | Treatment |
|---------|-----------|
| Section header | All caps, letter-spaced, slightly smaller |
| Toggle track | Deep purple/gray when on |
| Preview button | Outlined, not filled; subtle |
| Help text | Italic, lower opacity |

---

## 10. Accessibility

### 10.1 VoiceOver Compatibility

Death Voice must work WITH VoiceOver, not against it:

```swift
// When VoiceOver is running, speak through VoiceOver system
if UIAccessibility.isVoiceOverRunning {
    UIAccessibility.post(
        notification: .announcement,
        argument: script
    )
} else {
    MortalityVoice.shared.speak(script)
}
```

### 10.2 Reduce Motion

When Reduce Motion is enabled:
- Skip screen dimming animation
- Skip breathing aura changes
- Voice still speaks (audio is unaffected)

### 10.3 Accessibility Labels

```swift
// Settings toggle
Toggle("Enable Voice", isOn: $voiceEnabled)
    .accessibilityLabel("Death Voice")
    .accessibilityHint("When enabled, a voice speaks observations about your time and milestones")

// Preview button
Button("Hear a preview") { ... }
    .accessibilityLabel("Preview Death Voice")
    .accessibilityHint("Plays a sample of what the voice sounds like")
```

---

## 11. Localization Considerations

### 11.1 Voice Selection by Language

```swift
func selectVoice(for language: String) -> AVSpeechSynthesisVoice? {
    let preferredVoices: [String: [String]] = [
        "en": ["Aaron", "Daniel", "Tom"],
        "es": ["Jorge", "Diego"],
        "de": ["Markus", "Viktor"],
        "fr": ["Thomas", "Daniel"],
        "ja": ["Otoya", "Kyoko"],
        // Add more as needed
    ]
    
    let langPrefix = String(language.prefix(2))
    guard let voiceNames = preferredVoices[langPrefix] else {
        return AVSpeechSynthesisVoice(language: language)
    }
    
    let available = AVSpeechSynthesisVoice.speechVoices()
        .filter { $0.language.hasPrefix(langPrefix) }
    
    for name in voiceNames {
        if let voice = available.first(where: { $0.name.contains(name) }) {
            return voice
        }
    }
    
    return available.first
}
```

### 11.2 Script Localization Notes

When localizing scripts, preserve:
- **Tone:** Calm, patient, observant
- **Brevity:** Short sentences, deliberate pauses
- **Neutrality:** No judgment, just observation
- **Personalization:** Use of {name} placeholder

Avoid:
- Idioms that don't translate
- Cultural death references (vary widely)
- Gendered language (Death is neutral)

---

## 12. Analytics & Measurement

### 12.1 Events to Track

```swift
enum DeathVoiceAnalytics {
    case voiceSpoke(triggerType: String)
    case voiceSkipped(reason: String)
    case voiceDisabled
    case voiceEnabled
    case frequencyChanged(to: String)
    case categoryToggled(category: String, enabled: Bool)
    case previewPlayed
}
```

### 12.2 Success Metrics

| Metric | Target | Why |
|--------|--------|-----|
| Voice enabled rate | >70% keep enabled after 1 week | Feature is valuable, not annoying |
| Frequency upgrade rate | >10% move to "More" | Users want more engagement |
| Milestone completion after voice | +15% vs. silent | Voice creates accountability |
| Return rate after absence notification | >40% return within 48h | Notifications are effective |

### 12.3 Failure Signals

Watch for:
- >30% disable within first session → Too aggressive on first run
- >50% disable within first week → Not providing value
- Low completion rates on voiced milestones → Voice not creating accountability
- High uninstall correlation with voice events → Feature is harmful

---

## 13. Future Extensions

### 13.1 Beyond Horizons View

Once proven in Horizons, Death could extend to:

| View | Potential Triggers |
|------|-------------------|
| Quality View | Long streaks of low ratings, patterns of unrated weeks |
| Focus View | First time viewing ghost number, viewing after major life event |
| Settings | Changing expected lifespan, viewing total time remaining |
| Onboarding | The scale revelation moment |

### 13.2 Deeper Personalization

Future versions could:
- Learn user's response patterns (what motivates vs. annoys)
- Adjust frequency based on engagement
- Develop "relationship" over time (Death's tone evolves)
- Reference past conversations ("Last time we spoke...")

### 13.3 Ritual Integration

Death could integrate with The Sunday Ritual:
- Speak during week rating
- Comment on quality patterns
- Acknowledge streaks of intentionality

---

## 14. Implementation Checklist

### Phase 1: Core Voice (Week 1)

- [ ] AVSpeechSynthesizer integration
- [ ] Voice selection logic
- [ ] DeathPersona parameters tuned
- [ ] Basic speak() function working
- [ ] Audio session configuration

### Phase 2: Trigger System (Week 2)

- [ ] Trigger types defined
- [ ] Priority system implemented
- [ ] Frequency limits working
- [ ] Session state machine
- [ ] Debounce logic

### Phase 3: Script Engine (Week 3)

- [ ] All scripts written
- [ ] Context interpolation ({name}, {weeks}, etc.)
- [ ] Random selection working
- [ ] No repeat prevention

### Phase 4: Settings & Control (Week 4)

- [ ] Settings UI designed
- [ ] Persistence (UserDefaults/AppStorage)
- [ ] Frequency modes
- [ ] Category toggles
- [ ] Preview button

### Phase 5: Horizons Integration (Week 5)

- [ ] View appear triggers
- [ ] Milestone creation triggers
- [ ] Milestone completion triggers
- [ ] Overdue detection
- [ ] Absence detection

### Phase 6: Polish (Week 6)

- [ ] Visual dimming effect
- [ ] VoiceOver compatibility
- [ ] Reduce Motion support
- [ ] Analytics events
- [ ] Edge case handling

---

## 15. Appendix: Complete Script Library

### A. Action Scripts

#### First Milestone Ever
```
"Your first horizon. I see you're making plans, {name}."
"Ah. You've decided to reach for something. Interesting."
"A commitment. The first of many, perhaps."
"So it begins. A future, marked."
"{name}. You've pinned something to the time you have left. I noticed."
```

#### Milestone Created (Subsequent)
```
"Another horizon. You're building a map of your remaining time."
"More plans. Good. Empty weeks serve no one."
"{count} horizons now. You're taking this seriously."
"The grid fills with intention. I observe."
"You continue to mark the future. Most do not."
"Noted. Another point on your map of time."
```

#### Milestone Completed
```
"You did it. {milestoneName}. I noticed."
"{milestoneName} is yours now. Well done, {name}."
"One horizon reached. The time was well spent."
"Claimed. That week had meaning."
"{name}. You finished {milestoneName}. I was watching."
"Another mark against the empty. You're doing well."
"Done. {milestoneName} is behind you now."
```

#### Milestone Deleted
```
"Gone. Perhaps it wasn't meant to be."
"You've released that one. The future reshapes."
"Deleted. I make no judgment. Time remains indifferent."
"A horizon removed. The grid simplifies."
"That one is no longer marked. I note it."
"Released. The future is lighter by one intention."
```

#### Milestone Moved Further
```
"Pushed further out. There's always more time. Until there isn't."
"Later, then. I understand. I can wait."
"The horizon recedes. Be careful it doesn't disappear entirely."
"Delayed. I have no opinion. Time does not care."
"Further out. You have your reasons."
"Postponed. The weeks remain. The intention wavers."
```

#### Milestone Moved Closer
```
"Sooner. You feel the pressure now. Good."
"Moved closer. Perhaps you realize time is shorter than it seems."
"Urgency. It suits you, {name}."
"Closer now. You're paying attention."
"The deadline approaches faster by your choice. Interesting."
"Accelerated. You're taking this seriously."
```

### B. Inaction Scripts

#### Milestone Overdue
```
"{milestoneName} has passed. The week is gone."
"You missed {milestoneName}. Time forgives nothing, {name}."
"That moment slipped away. I was there. You weren't."
"Overdue. The window closed. There may be others."
"{milestoneName} came and went. I noticed your absence."
"The deadline passed. {milestoneName} remains unclaimed."
```

#### Returns After Absence
```
"It's been {weeks} weeks, {name}. I've been here the whole time."
"You were away. {weeks} weeks vanished. Did you notice?"
"Welcome back. {weeks} weeks have passed. They won't return."
"{weeks} weeks since we last spoke. The grid grew shorter."
"Ah, {name}. {weeks} weeks. I wondered if you'd return."
"Time moved on without you. {weeks} weeks. I kept count."
"{name}. You've returned. {weeks} weeks passed in your absence."
```

#### No Milestones Exist
```
"No horizons. The future is a blank page, {name}. Is that intentional?"
"Nothing planned. Every week the same as the last. Is that enough for you?"
"An empty grid. Some find peace in that. Others find nothing."
"You've set no horizons. Time will pass regardless."
"The future is unmarked. That's your choice to make."
"I see no intentions here. Just empty weeks waiting."
"A life without markers. Perhaps that's freedom. Perhaps not."
```

#### Multiple Overdue (Pattern)
```
"Three horizons have passed you by now. A pattern emerges."
"You set intentions. You let them slip. I'm only observing."
"The overdue pile grows. Do these still matter to you?"
"Three missed. Perhaps the targets were unrealistic. Or perhaps not."
"A pattern of delay. I note it without judgment."
"Several horizons, all overdue. What does that tell you, {name}?"
```

#### Approaching (Notification)
```
Title: "{milestoneName}"
Body: "2 weeks remain. — Death"

Title: "{milestoneName}"
Body: "{weeks} weeks. The horizon approaches."

Title: "A deadline draws near"
Body: "{milestoneName}. {weeks} weeks."
```

---

**Document History:**
- v1.0 — Initial Death Voice PRD (December 2025)

---

*"Death is not your enemy. Death is your witness."*

*"I am patient. I am inevitable. I am counting."*

*"The grid is not empty weeks until you die. It is full weeks you get to design."*