# Finite — Apple Intelligence Specification

> Technical specification for V1.5 "Reflect" feature  
> **Version:** 1.0.0  
> **Last Updated:** December 17, 2024  
> **Target Release:** V1.5 (4-6 weeks post-MVP)  
> **iOS Requirement:** iOS 26+ (Foundation Models framework)  
> **Device Requirement:** iPhone 15 Pro or later (Apple Silicon with Neural Engine)

---

## Overview

Apple Intelligence integration adds an on-device AI "Reflect" feature that lets users query their life data conversationally. All processing happens locally—no cloud, no API costs, maintains "Data Not Collected" privacy label.

### Why V1.5, Not V1

1. **MVP scope risk** — Adds 2-3 sprints to 6-sprint plan
2. **Device limitation** — Only ~30-40% of users have iPhone 15 Pro+
3. **Need user data first** — AI requires marked weeks to analyze
4. **Core polish priority** — The Reveal animation is the signature moment; ship that first
5. **Precedent** — Day One, Stoic followed same pattern (core first, AI enhancement later)

---

## Technical Foundation

### Framework: Foundation Models (iOS 26+)

Apple's on-device LLM framework provides:
- ~3B parameter model running locally
- Zero API costs
- Works offline
- Sub-second response times for short queries
- Full privacy preservation

### Key Capabilities

| Capability | Use in Finite |
|------------|---------------|
| **Tool Calling** | LLM queries SwiftData directly for weeks, phases, ratings |
| **Guided Generation** | Type-safe Swift structs for structured insight responses |
| **Streaming** | Progressive UI updates during generation |
| **Graceful Degradation** | Feature hidden on unsupported devices |

---

## Feature: "Reflect"

### User Experience

User taps "Reflect" button (or asks via natural language input) and can query their life data:

**Example queries:**
- "What were my best months this year?"
- "Show patterns in my work weeks"
- "How has my rating changed over time?"
- "What categories dominated my 20s?"
- "Compare this year to last year"

**Response format:**
- Structured insight card (not chatbot-style text)
- Optional timeline visualization highlighting relevant weeks
- Tone: contemplative/stark, not wellness-coded

### UI Concept

```
┌─────────────────────────────────────────────┐
│                  Reflect                     │
│─────────────────────────────────────────────│
│                                             │
│  ┌─────────────────────────────────────┐   │
│  │ What patterns do you see in my      │   │
│  │ weeks?                               │   │
│  └─────────────────────────────────────┘   │
│                                             │
│  ┌─────────────────────────────────────┐   │
│  │  📊 Insight                          │   │
│  │                                      │   │
│  │  Your highest-rated weeks cluster   │   │
│  │  around Q2 each year. Work weeks    │   │
│  │  average 3.2, while Adventure       │   │
│  │  weeks average 4.6.                 │   │
│  │                                      │   │
│  │  [View on grid]                     │   │
│  └─────────────────────────────────────┘   │
│                                             │
└─────────────────────────────────────────────┘
```

---

## Implementation Details

### 1. Check Device Capability

```swift
import FoundationModels

func isAppleIntelligenceAvailable() -> Bool {
    guard #available(iOS 26, *) else { return false }
    return SystemLanguageModel.isAvailable
}

// In Settings or feature gate
if isAppleIntelligenceAvailable() {
    // Show Reflect feature
} else {
    // Hide or show "Requires iPhone 15 Pro+" message
}
```

### 2. Define Tools for Data Access

Tools let the LLM query your SwiftData store with type-safe parameters:

```swift
import FoundationModels

@Tool
struct QueryWeeksTool {
    /// Query marked weeks from the user's life grid
    /// - Parameters:
    ///   - startWeek: First week number to include (optional)
    ///   - endWeek: Last week number to include (optional)
    ///   - category: Filter by category (optional)
    ///   - minRating: Minimum rating to include (optional)
    /// - Returns: Array of week summaries
    func call(
        startWeek: Int? = nil,
        endWeek: Int? = nil,
        category: String? = nil,
        minRating: Int? = nil
    ) async throws -> [WeekSummary] {
        // Query SwiftData
        let descriptor = FetchDescriptor<Week>(
            predicate: buildPredicate(startWeek, endWeek, category, minRating),
            sortBy: [SortDescriptor(\.weekNumber)]
        )
        let weeks = try modelContext.fetch(descriptor)
        return weeks.map { WeekSummary(from: $0) }
    }
}

@Tool
struct QueryPhasesTool {
    /// Get user's life phases/chapters
    /// - Returns: Array of life phases with date ranges
    func call() async throws -> [PhaseSummary] {
        let descriptor = FetchDescriptor<LifePhase>(
            sortBy: [SortDescriptor(\.startYear)]
        )
        let phases = try modelContext.fetch(descriptor)
        return phases.map { PhaseSummary(from: $0) }
    }
}

@Tool  
struct GetLifeStatsTool {
    /// Get aggregate statistics about the user's life data
    /// - Returns: Overall stats like total weeks marked, average rating, etc.
    func call() async throws -> LifeStats {
        let weeks = try modelContext.fetch(FetchDescriptor<Week>())
        let marked = weeks.filter { $0.rating != nil }
        
        return LifeStats(
            totalWeeksLived: user.currentWeekNumber,
            weeksMarked: marked.count,
            averageRating: marked.map { $0.rating! }.average(),
            categoryBreakdown: computeCategoryBreakdown(marked),
            ratingDistribution: computeRatingDistribution(marked)
        )
    }
}
```

### 3. Define Structured Output Types

Use `@Generable` for type-safe responses (no text parsing):

```swift
import FoundationModels

@Generable
struct LifeInsight {
    /// A brief, contemplative observation about the user's life data
    let observation: String
    
    /// Specific weeks that support this insight (for highlighting on grid)
    let relevantWeeks: [Int]
    
    /// Category of insight
    let insightType: InsightType
    
    /// Confidence level (0.0 to 1.0)
    let confidence: Double
}

@Generable
enum InsightType: String {
    case pattern      // Recurring patterns detected
    case comparison   // Comparing time periods
    case trend        // Changes over time
    case highlight    // Notable peaks or valleys
    case category     // Category-based insights
}

@Generable
struct ReflectResponse {
    /// Primary insight to display
    let insight: LifeInsight
    
    /// Optional follow-up questions user might ask
    let suggestedFollowUps: [String]?
}
```

### 4. Create Session and Generate

```swift
import FoundationModels

class ReflectService {
    private var session: LanguageModelSession?
    
    func initialize() async throws {
        guard isAppleIntelligenceAvailable() else {
            throw ReflectError.notAvailable
        }
        
        let configuration = SessionConfiguration(
            instructions: """
                You are a contemplative assistant helping users reflect on their life data.
                
                Tone guidelines:
                - Be stark and honest, not warm and fuzzy
                - Observations should provoke thought, not comfort
                - Use precise language, avoid wellness clichés
                - When discussing time, emphasize its finite nature
                
                You have access to the user's life grid data through tools.
                Always query the data before making observations.
                Never invent or assume data that wasn't returned by tools.
                """
        )
        
        session = LanguageModelSession(
            configuration: configuration,
            tools: [QueryWeeksTool(), QueryPhasesTool(), GetLifeStatsTool()]
        )
    }
    
    func reflect(query: String) async throws -> ReflectResponse {
        guard let session = session else {
            throw ReflectError.notInitialized
        }
        
        let response = try await session.respond(
            to: query,
            generating: ReflectResponse.self
        )
        
        return response
    }
}
```

### 5. Streaming for Progressive UI

```swift
func reflectWithStreaming(query: String) async throws {
    guard let session = session else { return }
    
    let stream = session.streamResponse(
        to: query,
        generating: ReflectResponse.self
    )
    
    for try await partial in stream {
        // Update UI progressively
        await MainActor.run {
            self.currentInsight = partial.insight?.observation ?? "Thinking..."
        }
    }
}
```

---

## Data Types for Tools

```swift
// Lightweight structs for tool responses (not full SwiftData models)

struct WeekSummary: Codable {
    let weekNumber: Int
    let rating: Int
    let category: String?
    let phrase: String?
    let phase: String?
    let year: Int
    let month: Int
    
    init(from week: Week) {
        self.weekNumber = week.weekNumber
        self.rating = week.rating ?? 3
        self.category = week.category?.rawValue
        self.phrase = week.phrase
        self.phase = week.phase?.name
        // Calculate year/month from weekNumber + birthDate
        self.year = calculateYear(week.weekNumber)
        self.month = calculateMonth(week.weekNumber)
    }
}

struct PhaseSummary: Codable {
    let name: String
    let startYear: Int
    let endYear: Int
    let defaultRating: Int?
    let weekCount: Int
}

struct LifeStats: Codable {
    let totalWeeksLived: Int
    let weeksMarked: Int
    let averageRating: Double
    let categoryBreakdown: [String: Int]
    let ratingDistribution: [Int: Int]
}
```

---

## Graceful Degradation

```swift
struct ReflectButton: View {
    var body: some View {
        if isAppleIntelligenceAvailable() {
            Button("Reflect") {
                // Open Reflect sheet
            }
        } else {
            // Option A: Hide completely
            EmptyView()
            
            // Option B: Show disabled with explanation
            Button("Reflect") {}
                .disabled(true)
                .overlay {
                    Text("Requires iPhone 15 Pro or later")
                        .font(.caption)
                }
        }
    }
}
```

---

## Privacy Alignment

| Aspect | Implementation |
|--------|----------------|
| Data transmission | None — all on-device |
| API keys | None required |
| Cloud processing | None |
| App Store label | Maintains "Data Not Collected" |
| User consent | Feature is opt-in (user initiates query) |

---

## Implementation Estimate

| Task | Duration |
|------|----------|
| Device capability detection | 0.5 day |
| Tool definitions | 1 day |
| Generable structs | 0.5 day |
| Session configuration + prompts | 1 day |
| Reflect UI (input + insight cards) | 2 days |
| Grid highlighting for relevant weeks | 1 day |
| Streaming implementation | 0.5 day |
| Testing + prompt tuning | 2 days |
| Edge cases + error handling | 1 day |
| **Total** | **~10 days (1.75 sprints)** |

---

## Testing Notes

1. **Simulator limitation** — Foundation Models may not work in Simulator; test on device
2. **Data requirement** — Need marked weeks to test insights; create test data set
3. **Prompt iteration** — Tone calibration requires multiple iterations
4. **Edge cases:**
   - No marked weeks yet
   - Only one phase
   - All weeks same rating
   - Query about time period with no data

---

## Future Enhancements (V2.0+)

- Proactive insights (weekly "reflection" notification with insight)
- Voice input via Siri integration
- Insight history / saved reflections
- Compare insights over time

---

## References

- [WWDC 2025: Foundation Models Framework](https://developer.apple.com/videos/play/wwdc2025/10215/) — *Update with actual session when available*
- [Apple Foundation Models Documentation](https://developer.apple.com/documentation/foundationmodels) — *Check for updates*
- Internal: `finite-apple-intelligence-analysis.md` — Original research document

---

*This spec is ready for implementation when V1.5 development begins. Ensure iOS 26 SDK is available before starting.*