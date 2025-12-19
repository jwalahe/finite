# Copilot Task: Horizons — Life Milestones System (V1.0)

> **Priority:** CRITICAL — Core differentiator feature  
> **Philosophy:** Your life has a past AND a future. Both deserve visualization.  
> **Design Goals:** Lowest friction, slick UX, best performance

---

## Executive Summary

Finite currently lets users reflect on their past (Chapters, Quality ratings). But goal-oriented users need to see their **future** on the same grid. Horizons transforms Finite from a reflection app into a **life planning system** by letting users pin milestones to future weeks.

**The insight:** Mortality IS the ultimate deadline. When you visualize a goal on your life grid, you're anchoring it to your finite existence. This creates "temporal scarcity" that dramatically increases commitment.

**Result:** Finite becomes the ONLY app that combines:
- ✅ Week-based life visualization
- ✅ Past reflection (phases, ratings)
- ✅ Future planning (milestones)
- ✅ Mortality context for both

---

## Core Concepts

### Two User Archetypes

| Reflectors | Achievers |
|------------|-----------|
| "How did I spend my life?" | "How will I spend my life?" |
| Look backward | Look forward |
| Chapters, Quality views | Horizons view |
| Mark past weeks | Mark future weeks |

**V1.0 serves BOTH archetypes.**

### The Four View Modes

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│    CHAPTERS ←→ QUALITY ←→ FOCUS ←→ HORIZONS                    │
│       ↑           ↑          ↑          ↑                       │
│    Past by      Past by    Raw       Future                     │
│    life stage   feeling    mortality  goals                     │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘

Swipe order: Chapters → Quality → Focus → Horizons → Chapters...
Dot indicator: ● ○ ○ ○ (4 dots now)
```

### Visual Language

| Element | Past (filled weeks) | Present (current week) | Future (empty weeks) | Milestone |
|---------|---------------------|------------------------|----------------------|-----------|
| Symbol | ● (solid dot) | ◉ (pulsing dot) | ○ (empty dot) | ⬡ (hexagon) |
| Meaning | Lived | Now | Remaining | Goal anchor |

---

## Data Model

### New Model: Milestone

```swift
// Core/Models/Milestone.swift

import SwiftData
import Foundation

@Model
class Milestone {
    var id: UUID
    var name: String
    var targetWeekNumber: Int  // Must be > user.currentWeekNumber
    var category: WeekCategory?
    var notes: String?
    var iconName: String?  // SF Symbol name, optional
    
    // State
    var isCompleted: Bool = false
    var completedAt: Date?
    var completedWeekNumber: Int?  // Actual week completed (may differ from target)
    
    // Metadata
    var createdAt: Date
    var updatedAt: Date
    
    // Relationships
    @Relationship(deleteRule: .nullify)
    var phase: LifePhase?  // Optional: milestone can belong to a future phase
    
    init(name: String, targetWeekNumber: Int, category: WeekCategory? = nil) {
        self.id = UUID()
        self.name = name
        self.targetWeekNumber = targetWeekNumber
        self.category = category
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
```

### Computed Properties Extension

```swift
extension Milestone {
    /// Weeks remaining until target
    func weeksRemaining(from currentWeek: Int) -> Int {
        return max(0, targetWeekNumber - currentWeek)
    }
    
    /// Target age based on user's birth date
    func targetAge(birthDate: Date) -> Int {
        let calendar = Calendar.current
        let birthYear = calendar.component(.year, from: birthDate)
        let targetYear = birthYear + (targetWeekNumber / 52)
        return targetYear - birthYear
    }
    
    /// Human-readable time until milestone
    func timeUntilDescription(from currentWeek: Int) -> String {
        let weeks = weeksRemaining(from: currentWeek)
        if weeks == 0 { return "This week" }
        if weeks == 1 { return "1 week" }
        if weeks < 52 { return "\(weeks) weeks" }
        
        let years = weeks / 52
        let remainingWeeks = weeks % 52
        if remainingWeeks == 0 {
            return years == 1 ? "1 year" : "\(years) years"
        }
        return "\(years)y \(remainingWeeks)w"
    }
    
    /// Is milestone overdue?
    var isOverdue: Bool {
        guard !isCompleted else { return false }
        // Would need current week passed in
        return false // Computed at view level
    }
    
    /// Status for display
    enum Status {
        case upcoming
        case thisWeek
        case overdue
        case completed
    }
    
    func status(currentWeek: Int) -> Status {
        if isCompleted { return .completed }
        if targetWeekNumber < currentWeek { return .overdue }
        if targetWeekNumber == currentWeek { return .thisWeek }
        return .upcoming
    }
}
```

### User Extension for Milestones

```swift
extension User {
    /// All milestones sorted by target week
    var sortedMilestones: [Milestone] {
        // Query from SwiftData context
        // Sorted by targetWeekNumber ascending
    }
    
    /// Upcoming milestones (not completed, not overdue)
    var upcomingMilestones: [Milestone] {
        sortedMilestones.filter { 
            !$0.isCompleted && $0.targetWeekNumber >= currentWeekNumber 
        }
    }
    
    /// Next milestone (soonest upcoming)
    var nextMilestone: Milestone? {
        upcomingMilestones.first
    }
    
    /// Milestones in a specific week
    func milestones(forWeek weekNumber: Int) -> [Milestone] {
        sortedMilestones.filter { $0.targetWeekNumber == weekNumber }
    }
}
```

---

## View Mode: Horizons

### Purpose

Horizons view is the **forward-looking** perspective. It dims the past and highlights:
1. Current week (pulsing)
2. Future weeks with milestones (hexagon markers)
3. Empty future (opportunity)

### Visual Design

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│                         finite                                  │
│                    "Launch Startup"                             │ ← Next milestone name
│                                                                 │
│  ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  │ ← Past dimmed (30%)
│  ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  │
│  ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░◉○○○○○○○○○○○○○○○○○○○○○○○  │ ← Current week pulsing
│  ○○○○○○○○○○○○○○○○○○○○○○○○○○○○○⬡○○○○○○○○○○○○○○○○○○○○○○○○○○○  │ ← Milestone marker
│  ○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○  │
│  ○○○○○○○○○○○○○○○○○○⬡○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○  │ ← Another milestone
│  ○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○  │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  ⬡ Launch Startup                              78 weeks │   │ ← Milestone Context Bar
│  │    Age 31 · Career                                  [+] │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│                        ○ ○ ○ ●                                  │ ← 4th dot active
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Horizons-Specific Components

#### 1. Header (Horizons Mode)

```swift
// Shows next milestone name as subtitle
var horizonsSubtitle: String {
    if let next = user.nextMilestone {
        return "\"\(next.name)\""
    }
    return "Set your first horizon"
}
```

**Styling:**
- Milestone name in quotes
- Font: body, text-secondary
- Crossfades when switching to Horizons view

#### 2. Grid Rendering (Horizons Mode)

```swift
// Features/Grid/HorizonsGridRenderer.swift

struct HorizonsGridRenderer {
    let user: User
    let milestones: [Milestone]
    let currentWeek: Int
    
    func colorForWeek(_ weekNumber: Int) -> Color {
        // Past weeks: dimmed
        if weekNumber < currentWeek {
            return Color("week-filled").opacity(0.3)
        }
        
        // Current week: full brightness (handled by pulse overlay)
        if weekNumber == currentWeek {
            return Color("week-current")
        }
        
        // Future weeks: empty color
        return Color("week-empty")
    }
    
    func hasMilestone(_ weekNumber: Int) -> Bool {
        milestones.contains { $0.targetWeekNumber == weekNumber && !$0.isCompleted }
    }
    
    func milestoneIcon(_ weekNumber: Int) -> String? {
        guard let milestone = milestones.first(where: { $0.targetWeekNumber == weekNumber }) else {
            return nil
        }
        return milestone.iconName ?? "hexagon.fill"
    }
}
```

#### 3. Milestone Marker Component

```swift
// Design/Components/MilestoneMarker.swift

struct MilestoneMarker: View {
    let milestone: Milestone
    let size: CGFloat  // Typically 8-10pt
    let isHighlighted: Bool
    
    @State private var isPulsing = false
    
    var body: some View {
        ZStack {
            // Base hexagon
            Image(systemName: milestone.iconName ?? "hexagon.fill")
                .font(.system(size: size))
                .foregroundStyle(markerColor)
            
            // Highlight ring (when tapped/selected)
            if isHighlighted {
                Image(systemName: "hexagon")
                    .font(.system(size: size + 4))
                    .foregroundStyle(markerColor.opacity(0.5))
                    .scaleEffect(isPulsing ? 1.3 : 1.0)
                    .opacity(isPulsing ? 0 : 0.8)
            }
        }
        .onAppear {
            if isHighlighted {
                withAnimation(.easeOut(duration: 1.2).repeatForever(autoreverses: false)) {
                    isPulsing = true
                }
            }
        }
    }
    
    private var markerColor: Color {
        if let category = milestone.category {
            return category.color
        }
        return Color("text-primary")
    }
}
```

#### 4. Milestone Context Bar (Horizons Footer)

Replaces Phase Context Bar when in Horizons view.

```swift
// Design/Components/MilestoneContextBar.swift

struct MilestoneContextBar: View {
    let milestone: Milestone?
    let currentWeek: Int
    let user: User
    let onTap: (() -> Void)?
    let onAddTap: (() -> Void)?
    
    var body: some View {
        if let milestone = milestone {
            // Show next milestone info
            Button(action: { onTap?() }) {
                HStack(spacing: 12) {
                    // Milestone icon
                    Image(systemName: milestone.iconName ?? "hexagon.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(categoryColor)
                    
                    // Milestone info
                    VStack(alignment: .leading, spacing: 2) {
                        Text(milestone.name)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.primary)
                            .lineLimit(1)
                        
                        HStack(spacing: 8) {
                            // Age
                            Text("Age \(milestone.targetAge(birthDate: user.birthDate))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            // Category
                            if let category = milestone.category {
                                Text("·")
                                    .foregroundStyle(.tertiary)
                                Text(category.displayName)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // Weeks remaining
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(milestone.weeksRemaining(from: currentWeek))")
                            .font(.title3.weight(.semibold).monospacedDigit())
                            .foregroundStyle(.primary)
                        Text("weeks")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                    
                    // Add more button
                    Button(action: { onAddTap?() }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                )
            }
            .buttonStyle(.plain)
        } else {
            // Empty state: No milestones
            EmptyMilestoneBar(onAddTap: onAddTap)
        }
    }
    
    private var categoryColor: Color {
        milestone?.category?.color ?? Color("text-primary")
    }
}

struct EmptyMilestoneBar: View {
    let onAddTap: (() -> Void)?
    
    var body: some View {
        Button(action: { onAddTap?() }) {
            HStack(spacing: 12) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(.secondary)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Set your first horizon")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.primary)
                    Text("Pin a goal to your future")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [6, 4]))
                    .foregroundStyle(Color("text-tertiary"))
            )
        }
        .buttonStyle(.plain)
    }
}
```

---

## Milestone Builder Sheet

### Purpose
Create or edit a milestone with minimal friction.

### Design

```
┌─────────────────────────────────────────────────────────────────┐
│                         ─────                                    │
│                                                                 │
│                    Add Horizon                                  │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │ Launch my startup                                        │   │ ← Name input
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                                                         │   │
│  │       ░░░░░░░░░░░░░░░░◉○○○○○○○○⬡○○○○○○○○○○○○          │   │ ← Mini grid preview
│  │       ░░░░░░░░░░░░░░░░○○○○○○○○○○○○○○○○○○○○○○          │   │
│  │                                                         │   │
│  │                  78 weeks · Age 31                      │   │
│  │                                                         │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  TARGET WEEK                                                    │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │    ◀  April 2027  ▶    │   Week 1,625   │   Age 31    │   │ ← Date/Week picker
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  CATEGORY (optional)                                            │
│  ┌────┐ ┌────┐ ┌────┐ ┌────┐ ┌────┐ ┌────┐                    │
│  │ 💼 │ │ ❤️ │ │ 📚 │ │ 👥 │ │ 🌙 │ │ 🧭 │                    │ ← Same categories
│  │Work│ │Hlth│ │Grow│ │Rel.│ │Rest│ │Advn│                    │
│  └────┘ └────┘ └────┘ └────┘ └────┘ └────┘                    │
│                                                                 │
│  NOTES (optional)                                               │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │ MVP ready, first paying customer                        │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                    Set Horizon                          │   │ ← Primary action
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Implementation

```swift
// Features/Milestones/MilestoneBuilderView.swift

struct MilestoneBuilderView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let user: User
    let mode: Mode
    let onSave: ((Milestone) -> Void)?
    let onDelete: (() -> Void)?
    
    enum Mode {
        case add
        case edit(Milestone)
    }
    
    // Form state
    @State private var name: String = ""
    @State private var targetWeekNumber: Int
    @State private var category: WeekCategory?
    @State private var notes: String = ""
    
    // UI state
    @State private var showDeleteConfirm = false
    
    init(user: User, mode: Mode, onSave: ((Milestone) -> Void)? = nil, onDelete: (() -> Void)? = nil) {
        self.user = user
        self.mode = mode
        self.onSave = onSave
        self.onDelete = onDelete
        
        // Initialize state based on mode
        switch mode {
        case .add:
            // Default to 1 year from now
            _targetWeekNumber = State(initialValue: user.currentWeekNumber + 52)
        case .edit(let milestone):
            _name = State(initialValue: milestone.name)
            _targetWeekNumber = State(initialValue: milestone.targetWeekNumber)
            _category = State(initialValue: milestone.category)
            _notes = State(initialValue: milestone.notes ?? "")
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Name input
                    nameSection
                    
                    // Mini grid preview
                    gridPreviewSection
                    
                    // Target week picker
                    targetWeekSection
                    
                    // Category picker
                    categorySection
                    
                    // Notes input
                    notesSection
                    
                    // Delete button (edit mode only)
                    if case .edit = mode {
                        deleteSection
                    }
                }
                .padding(24)
            }
            .background(Color("bg-primary"))
            .navigationTitle(isEditMode ? "Edit Horizon" : "Add Horizon")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditMode ? "Save" : "Set Horizon") {
                        saveAndDismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                    .fontWeight(.semibold)
                }
            }
        }
        .confirmationDialog("Delete Horizon?", isPresented: $showDeleteConfirm) {
            Button("Delete", role: .destructive) {
                onDelete?()
                dismiss()
            }
        } message: {
            Text("This cannot be undone.")
        }
    }
    
    // MARK: - Sections
    
    private var nameSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("WHAT'S YOUR HORIZON?")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            TextField("Launch my startup", text: $name)
                .font(.title3)
                .padding(12)
                .background(Color("bg-secondary"))
                .cornerRadius(8)
        }
    }
    
    private var gridPreviewSection: some View {
        VStack(spacing: 12) {
            // Mini grid showing current → target
            MilestoneGridPreview(
                user: user,
                targetWeekNumber: targetWeekNumber
            )
            .frame(height: 60)
            
            // Stats
            HStack(spacing: 16) {
                Text("\(weeksRemaining) weeks")
                    .font(.subheadline.weight(.medium))
                Text("·")
                    .foregroundStyle(.tertiary)
                Text("Age \(targetAge)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .background(Color("bg-secondary"))
        .cornerRadius(12)
    }
    
    private var targetWeekSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("TARGET")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            MilestoneWeekPicker(
                user: user,
                selectedWeekNumber: $targetWeekNumber
            )
        }
    }
    
    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("CATEGORY (optional)")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            CategoryPicker(selection: $category)
        }
    }
    
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("NOTES (optional)")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            TextField("What does achieving this look like?", text: $notes, axis: .vertical)
                .lineLimit(3...6)
                .padding(12)
                .background(Color("bg-secondary"))
                .cornerRadius(8)
        }
    }
    
    private var deleteSection: some View {
        Button(role: .destructive) {
            showDeleteConfirm = true
        } label: {
            HStack {
                Image(systemName: "trash")
                Text("Delete Horizon")
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
        }
        .buttonStyle(.bordered)
        .tint(.red)
    }
    
    // MARK: - Computed
    
    private var isEditMode: Bool {
        if case .edit = mode { return true }
        return false
    }
    
    private var weeksRemaining: Int {
        max(0, targetWeekNumber - user.currentWeekNumber)
    }
    
    private var targetAge: Int {
        let calendar = Calendar.current
        let birthYear = calendar.component(.year, from: user.birthDate)
        return birthYear + (targetWeekNumber / 52) - birthYear
    }
    
    // MARK: - Actions
    
    private func saveAndDismiss() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }
        
        switch mode {
        case .add:
            let milestone = Milestone(
                name: trimmedName,
                targetWeekNumber: targetWeekNumber,
                category: category
            )
            milestone.notes = notes.isEmpty ? nil : notes
            modelContext.insert(milestone)
            onSave?(milestone)
            
        case .edit(let milestone):
            milestone.name = trimmedName
            milestone.targetWeekNumber = targetWeekNumber
            milestone.category = category
            milestone.notes = notes.isEmpty ? nil : notes
            milestone.updatedAt = Date()
            onSave?(milestone)
        }
        
        HapticService.shared.notification(.success)
        dismiss()
    }
}
```

### Week Picker Component

```swift
// Design/Components/MilestoneWeekPicker.swift

struct MilestoneWeekPicker: View {
    let user: User
    @Binding var selectedWeekNumber: Int
    
    // Computed date from week number
    private var selectedDate: Date {
        let calendar = Calendar.current
        let weeksSinceBirth = selectedWeekNumber
        return calendar.date(byAdding: .weekOfYear, value: weeksSinceBirth, to: user.birthDate) ?? Date()
    }
    
    // Minimum date: next week
    private var minimumDate: Date {
        let calendar = Calendar.current
        return calendar.date(byAdding: .weekOfYear, value: user.currentWeekNumber + 1, to: user.birthDate) ?? Date()
    }
    
    // Maximum date: end of expected life
    private var maximumDate: Date {
        let calendar = Calendar.current
        return calendar.date(byAdding: .weekOfYear, value: user.totalWeeks, to: user.birthDate) ?? Date()
    }
    
    var body: some View {
        HStack(spacing: 0) {
            // Date-based picker
            DatePicker(
                "",
                selection: Binding(
                    get: { selectedDate },
                    set: { newDate in
                        selectedWeekNumber = weekNumber(for: newDate)
                    }
                ),
                in: minimumDate...maximumDate,
                displayedComponents: .date
            )
            .datePickerStyle(.compact)
            .labelsHidden()
            
            Spacer()
            
            // Week number display
            VStack(alignment: .trailing, spacing: 2) {
                Text("Week \(selectedWeekNumber.formatted())")
                    .font(.subheadline.monospacedDigit())
                    .foregroundStyle(.secondary)
                Text("Age \(targetAge)")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(12)
        .background(Color("bg-secondary"))
        .cornerRadius(8)
    }
    
    private func weekNumber(for date: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.weekOfYear], from: user.birthDate, to: date)
        return max(user.currentWeekNumber + 1, (components.weekOfYear ?? 0) + 1)
    }
    
    private var targetAge: Int {
        selectedWeekNumber / 52
    }
}
```

### Mini Grid Preview

```swift
// Design/Components/MilestoneGridPreview.swift

struct MilestoneGridPreview: View {
    let user: User
    let targetWeekNumber: Int
    
    // Show ~10 years around current week
    private let visibleWeeks = 520  // 10 years
    
    var body: some View {
        GeometryReader { geo in
            Canvas { context, size in
                let dotSize: CGFloat = 3
                let spacing: CGFloat = 1
                let cols = Int(size.width / (dotSize + spacing))
                let startWeek = max(0, user.currentWeekNumber - (visibleWeeks / 4))
                let endWeek = startWeek + visibleWeeks
                
                for i in 0..<visibleWeeks {
                    let weekNum = startWeek + i
                    let col = i % cols
                    let row = i / cols
                    let x = CGFloat(col) * (dotSize + spacing)
                    let y = CGFloat(row) * (dotSize + spacing)
                    
                    let rect = CGRect(x: x, y: y, width: dotSize, height: dotSize)
                    
                    // Determine color
                    let color: Color
                    if weekNum == targetWeekNumber {
                        color = Color("text-primary")  // Milestone marker
                    } else if weekNum == user.currentWeekNumber {
                        color = Color("week-current")
                    } else if weekNum < user.currentWeekNumber {
                        color = Color("week-filled").opacity(0.3)
                    } else {
                        color = Color("week-empty")
                    }
                    
                    // Draw
                    if weekNum == targetWeekNumber {
                        // Hexagon for milestone
                        let path = hexagonPath(in: rect)
                        context.fill(path, with: .color(color))
                    } else {
                        context.fill(Path(ellipseIn: rect), with: .color(color))
                    }
                }
            }
        }
    }
    
    private func hexagonPath(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = rect.width / 2
        
        for i in 0..<6 {
            let angle = CGFloat(i) * .pi / 3 - .pi / 6
            let point = CGPoint(
                x: center.x + radius * cos(angle),
                y: center.y + radius * sin(angle)
            )
            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.closeSubpath()
        return path
    }
}
```

---

## Milestone Interactions Across All Views

### Chapters View
- Milestones appear as hexagon markers on future weeks
- Tapping a milestone opens detail sheet
- Milestones can optionally belong to a phase

### Quality View
- Milestones appear as hexagon markers
- Future weeks with milestones are tappable (opens milestone detail)
- Past weeks tappable for rating (existing behavior)

### Focus View
- Milestones appear as subtle hexagon markers (less prominent)
- Ghost number still primary focus
- Tapping milestone summons countdown instead of milestone name

### Horizons View
- Full milestone experience
- Past is dimmed
- Milestones are prominent
- Context bar shows next milestone
- Tap milestone markers to edit/view

---

## Milestone Detail Sheet

When tapping an existing milestone:

```swift
// Features/Milestones/MilestoneDetailSheet.swift

struct MilestoneDetailSheet: View {
    let milestone: Milestone
    let user: User
    let onEdit: (() -> Void)?
    let onComplete: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                Image(systemName: milestone.iconName ?? "hexagon.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(categoryColor)
                
                Text(milestone.name)
                    .font(.title2.weight(.semibold))
                    .multilineTextAlignment(.center)
                
                if let category = milestone.category {
                    Text(category.displayName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            
            // Stats
            HStack(spacing: 32) {
                statBlock(
                    value: "\(milestone.weeksRemaining(from: user.currentWeekNumber))",
                    label: "weeks"
                )
                statBlock(
                    value: "\(milestone.targetAge(birthDate: user.birthDate))",
                    label: "age"
                )
                statBlock(
                    value: targetDateString,
                    label: "target"
                )
            }
            
            // Notes
            if let notes = milestone.notes, !notes.isEmpty {
                Text(notes)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(Color("bg-secondary"))
                    .cornerRadius(8)
            }
            
            Spacer()
            
            // Actions
            VStack(spacing: 12) {
                // Complete button
                Button {
                    onComplete?()
                } label: {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Mark Complete")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                
                // Edit button
                Button {
                    onEdit?()
                } label: {
                    Text("Edit Horizon")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.bordered)
            }
        }
        .padding(24)
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
    
    private var categoryColor: Color {
        milestone.category?.color ?? Color("text-primary")
    }
    
    private var targetDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        let calendar = Calendar.current
        let date = calendar.date(byAdding: .weekOfYear, value: milestone.targetWeekNumber, to: user.birthDate) ?? Date()
        return formatter.string(from: date)
    }
    
    private func statBlock(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title.weight(.semibold).monospacedDigit())
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
```

---

## Completing a Milestone

When a milestone is completed:

1. Mark `isCompleted = true`, `completedAt = Date()`, `completedWeekNumber = user.currentWeekNumber`
2. Show celebration (optional, subtle)
3. Milestone moves to "Completed" section in settings
4. Grid marker changes to checkmark or fades

```swift
// Completion logic
func completeMilestone(_ milestone: Milestone, currentWeek: Int) {
    milestone.isCompleted = true
    milestone.completedAt = Date()
    milestone.completedWeekNumber = currentWeek
    milestone.updatedAt = Date()
    
    HapticService.shared.notification(.success)
}
```

---

## Integration with GridView

### Updated View Mode Enum

```swift
enum ViewMode: String, Codable, CaseIterable {
    case chapters
    case quality
    case focus
    case horizons
    
    var displayName: String {
        switch self {
        case .chapters: return "Chapters"
        case .quality: return "Quality"
        case .focus: return "Focus"
        case .horizons: return "Horizons"
        }
    }
    
    var next: ViewMode {
        switch self {
        case .chapters: return .quality
        case .quality: return .focus
        case .focus: return .horizons
        case .horizons: return .chapters
        }
    }
    
    var previous: ViewMode {
        switch self {
        case .chapters: return .horizons
        case .quality: return .chapters
        case .focus: return .quality
        case .horizons: return .focus
        }
    }
}
```

### GridView Updates

```swift
// Features/Grid/GridView.swift — Key additions

struct GridView: View {
    @Query private var milestones: [Milestone]
    @State private var selectedMilestone: Milestone?
    @State private var showMilestoneBuilder = false
    @State private var milestoneToEdit: Milestone?
    
    var body: some View {
        ZStack {
            // Main content
            VStack(spacing: 0) {
                // Header with view-specific subtitle
                headerView
                
                // Grid
                gridContent
                
                // Footer based on view mode
                footerView
                
                // Dot indicator (4 dots now)
                ViewModeIndicator(currentMode: viewMode, totalModes: 4)
            }
            
            // Walkthrough overlay
            if walkthrough.isActive {
                WalkthroughOverlay(...)
            }
        }
        .gesture(viewModeSwipeGesture)
        
        // Milestone sheets
        .sheet(isPresented: $showMilestoneBuilder) {
            MilestoneBuilderView(
                user: user,
                mode: milestoneToEdit.map { .edit($0) } ?? .add,
                onSave: { milestone in
                    // Handle save
                },
                onDelete: {
                    if let milestone = milestoneToEdit {
                        modelContext.delete(milestone)
                    }
                }
            )
        }
        .sheet(item: $selectedMilestone) { milestone in
            MilestoneDetailSheet(
                milestone: milestone,
                user: user,
                onEdit: {
                    selectedMilestone = nil
                    milestoneToEdit = milestone
                    showMilestoneBuilder = true
                },
                onComplete: {
                    completeMilestone(milestone, currentWeek: user.currentWeekNumber)
                    selectedMilestone = nil
                }
            )
        }
    }
    
    // MARK: - Footer
    
    @ViewBuilder
    private var footerView: some View {
        switch viewMode {
        case .chapters:
            PhaseContextBar(
                phase: currentPhase,
                viewMode: viewMode,
                onTap: { /* edit phase */ }
            )
        case .quality:
            // Existing quality footer
            EmptyView()
        case .focus:
            // Ghost number
            GhostNumber(weeksRemaining: user.weeksRemaining)
        case .horizons:
            MilestoneContextBar(
                milestone: user.nextMilestone,
                currentWeek: user.currentWeekNumber,
                user: user,
                onTap: {
                    if let next = user.nextMilestone {
                        selectedMilestone = next
                    }
                },
                onAddTap: {
                    milestoneToEdit = nil
                    showMilestoneBuilder = true
                }
            )
        }
    }
    
    // MARK: - Grid Rendering
    
    private func colorForWeek(_ weekNumber: Int) -> Color {
        switch viewMode {
        case .chapters:
            return chaptersColor(for: weekNumber)
        case .quality:
            return qualityColor(for: weekNumber)
        case .focus:
            return focusColor(for: weekNumber)
        case .horizons:
            return horizonsColor(for: weekNumber)
        }
    }
    
    private func horizonsColor(for weekNumber: Int) -> Color {
        if weekNumber < user.currentWeekNumber {
            return Color("week-filled").opacity(0.3)  // Dimmed past
        } else if weekNumber == user.currentWeekNumber {
            return Color("week-current")
        } else {
            return Color("week-empty")
        }
    }
    
    private func milestoneForWeek(_ weekNumber: Int) -> Milestone? {
        milestones.first { $0.targetWeekNumber == weekNumber && !$0.isCompleted }
    }
}
```

---

## Settings Integration

Add milestone management to Settings:

```swift
// Features/Settings/SettingsView.swift

// Add section
SettingsSection(title: "HORIZONS") {
    NavigationLink {
        MilestoneListView(user: user)
    } label: {
        SettingsRow(
            icon: "hexagon.fill",
            label: "Manage Horizons",
            value: "\(upcomingMilestones.count) active"
        )
    }
}
```

```swift
// Features/Settings/MilestoneListView.swift

struct MilestoneListView: View {
    let user: User
    @Query(sort: \Milestone.targetWeekNumber) private var milestones: [Milestone]
    
    var upcomingMilestones: [Milestone] {
        milestones.filter { !$0.isCompleted }
    }
    
    var completedMilestones: [Milestone] {
        milestones.filter { $0.isCompleted }
    }
    
    var body: some View {
        List {
            Section("Upcoming") {
                ForEach(upcomingMilestones) { milestone in
                    MilestoneRow(milestone: milestone, user: user)
                }
                .onDelete(perform: deleteUpcoming)
            }
            
            if !completedMilestones.isEmpty {
                Section("Completed") {
                    ForEach(completedMilestones) { milestone in
                        MilestoneRow(milestone: milestone, user: user, isCompleted: true)
                    }
                }
            }
        }
        .navigationTitle("Horizons")
    }
}
```

---

## Walkthrough Update

Add Horizons to walkthrough flow:

### New Step: Horizons Introduction

After Focus view step, add:

```swift
case .horizonsIntro:
    title = "Your Horizons"
    message = "Pin life goals to future weeks.\nSee exactly how many weeks until you get there."
    actionHint = "Swipe right to try"

case .addMilestone:
    title = "Set Your First Horizon"
    message = "What do you want to achieve?\nTap + to add a milestone."
    actionHint = "Tap +"
```

---

## Animation Specifications

| Interaction | Animation | Duration |
|-------------|-----------|----------|
| Milestone marker appear | Scale in + fade | 0.2s snappy |
| Milestone marker pulse (highlighted) | Scale 1.0 → 1.3, opacity 0.8 → 0 | 1.2s loop |
| Past dimming (Horizons view) | Opacity 1.0 → 0.3 | 0.3s ease-out |
| Milestone context bar appear | Slide up + fade | 0.25s smooth |
| Week picker change | Crossfade grid preview | 0.2s ease-out |
| Milestone complete | Scale up + checkmark | 0.3s bouncy |

---

## Haptic Specifications

| Interaction | Haptic |
|-------------|--------|
| Tap milestone marker | `.light` impact |
| Open milestone builder | `.light` impact |
| Change target week | `.selection` feedback |
| Save milestone | `.success` notification |
| Complete milestone | `.success` notification |
| Delete milestone | `.medium` impact |

---

## Performance Considerations

### Milestone Query Optimization

```swift
// Only query future milestones for grid rendering
@Query(
    filter: #Predicate<Milestone> { !$0.isCompleted },
    sort: \Milestone.targetWeekNumber
) private var activeMilestones: [Milestone]
```

### Grid Rendering

```swift
// Cache milestone week numbers for fast lookup
private var milestoneWeekSet: Set<Int> {
    Set(activeMilestones.map { $0.targetWeekNumber })
}

// O(1) lookup in grid render
func hasMilestone(_ weekNumber: Int) -> Bool {
    milestoneWeekSet.contains(weekNumber)
}
```

---

## Accessibility

```swift
// Milestone marker
MilestoneMarker(...)
    .accessibilityLabel("\(milestone.name), target age \(milestone.targetAge)")
    .accessibilityHint("Double tap to view details")
    .accessibilityAddTraits(.isButton)

// Context bar
MilestoneContextBar(...)
    .accessibilityLabel("Next horizon: \(milestone.name), \(milestone.weeksRemaining) weeks remaining")
    .accessibilityHint("Double tap to view or edit")

// Empty state
EmptyMilestoneBar(...)
    .accessibilityLabel("No horizons set")
    .accessibilityHint("Double tap to add your first life goal")
```

---

## Files to Create

| File | Purpose |
|------|---------|
| `Core/Models/Milestone.swift` | Data model |
| `Features/Milestones/MilestoneBuilderView.swift` | Create/edit sheet |
| `Features/Milestones/MilestoneDetailSheet.swift` | View milestone details |
| `Features/Milestones/MilestoneListView.swift` | Settings list view |
| `Design/Components/MilestoneMarker.swift` | Grid marker component |
| `Design/Components/MilestoneContextBar.swift` | Horizons footer |
| `Design/Components/MilestoneWeekPicker.swift` | Target week selector |
| `Design/Components/MilestoneGridPreview.swift` | Mini grid in builder |

## Files to Modify

| File | Changes |
|------|---------|
| `Core/Models/ViewMode.swift` | Add `.horizons` case |
| `Features/Grid/GridView.swift` | 4th view mode, milestone rendering |
| `Features/Grid/GridRenderer.swift` | Milestone markers on grid |
| `Features/Settings/SettingsView.swift` | Horizons management section |
| `Design/Components/ViewModeIndicator.swift` | 4 dots instead of 3 |
| `Core/Services/WalkthroughService.swift` | Horizons steps |

---

## Testing Checklist

### Milestone CRUD
- [ ] Create milestone with all fields
- [ ] Create milestone with minimum fields (name + target only)
- [ ] Edit milestone name
- [ ] Edit milestone target week
- [ ] Edit milestone category
- [ ] Delete milestone
- [ ] Complete milestone

### Grid Display
- [ ] Milestone markers appear on correct weeks
- [ ] Markers visible in all 4 view modes
- [ ] Horizons view dims past correctly
- [ ] Tapping marker opens detail sheet
- [ ] Multiple milestones on different weeks render correctly

### Context Bar
- [ ] Shows next upcoming milestone
- [ ] Shows correct week countdown
- [ ] Shows correct age
- [ ] Empty state shows when no milestones
- [ ] Add button opens builder
- [ ] Tap opens detail sheet

### Week Picker
- [ ] Cannot select past weeks
- [ ] Cannot select current week
- [ ] Date picker syncs with week number
- [ ] Grid preview updates live
- [ ] Age calculates correctly

### View Mode Integration
- [ ] Swipe right from Focus goes to Horizons
- [ ] Swipe left from Horizons goes to Focus
- [ ] Swipe right from Horizons goes to Chapters
- [ ] Dot indicator shows 4 dots
- [ ] Correct dot highlighted per mode

### Edge Cases
- [ ] User with 0 milestones
- [ ] User with 50+ milestones
- [ ] Milestone targeted at max life expectancy
- [ ] Milestone targeted at next week
- [ ] Completing overdue milestone
- [ ] Completing milestone early

---

## Summary

This spec adds the **Horizons** feature to V1.0, transforming Finite from a reflection-only app into a complete life planning system.

**Key additions:**
1. **Milestone data model** — Goals pinned to future weeks
2. **4th view mode (Horizons)** — Forward-looking perspective
3. **Milestone markers** — Hexagon icons on future weeks
4. **Milestone builder** — Create/edit with mini grid preview
5. **Milestone context bar** — Shows next goal + countdown
6. **Settings integration** — Manage all horizons

**The result:** The only app that visualizes both your past chapters AND your future horizons on the same life grid. Time becomes not just something you've spent, but something you're investing toward specific goals.

*"Your life has a past AND a future. Both deserve visualization."*