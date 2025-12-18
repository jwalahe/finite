# Copilot Task: Settings Screen Redesign

## Context

Finite is a "life in weeks" mortality visualization app. The current Settings screen uses default iOS `Form`/`List` styling which feels generic and breaks the contemplative, stark aesthetic of the app.

**App Philosophy Reminder:**
- Stark over soft
- Craft over features
- Ritual over utility
- The grid is the hero

Settings should feel like part of the app, not an escape from it.

---

## Current State

The Settings screen likely uses native iOS Form/List with default styling:
- System gray grouped background
- Standard chevrons and toggles
- Generic feel that doesn't match the app

**Location:** `Features/Settings/SettingsView.swift`

---

## Desired Design

### Visual Style

```
┌─────────────────────────────────────────┐
│                                         │
│              Settings                   │  ← title-md, centered
│                                         │
│─────────────────────────────────────────│
│                                         │
│  YOUR LIFE                              │  ← Section header: caption, text-tertiary, uppercase
│                                         │
│  Born                    March 15, 1996 │  ← Row: body left, body-emphasis right
│  Expected lifespan              80 years│
│                                         │
│─────────────────────────────────────────│
│                                         │
│  CHAPTERS                               │
│                                         │
│  Manage phases                        → │  ← Only navigation items get chevron
│                                         │
│─────────────────────────────────────────│
│                                         │
│  REMINDERS                              │
│                                         │
│  Daily notification              8:00 AM│
│  Milestone alerts                    On │
│                                         │
│─────────────────────────────────────────│
│                                         │
│  DATA                                   │
│                                         │
│  Export life grid                     → │
│  Erase everything                     → │  ← Destructive: text-red
│                                         │
│─────────────────────────────────────────│
│                                         │
│              finite v1.0                │  ← caption, text-tertiary
│       "Hurry up and live." — Seneca     │  ← caption-sm, text-tertiary, italic
│                                         │
└─────────────────────────────────────────┘
```

### Color Specifications

| Element | Light Mode | Dark Mode |
|---------|------------|-----------|
| Background | #FAFAFA (bg-primary) | #0A0A0A (bg-primary) |
| Section header | #9A9A9A (text-tertiary) | #636366 (text-tertiary) |
| Row label | #1A1A1A (text-primary) | #F5F5F5 (text-primary) |
| Row value | #1A1A1A (text-primary) | #F5F5F5 (text-primary) |
| Divider | #E5E5E5 (border) | #38383A (border) |
| Destructive | #DC2626 | #DC2626 |

### Typography

| Element | Style |
|---------|-------|
| Screen title | 28pt Bold (title-md), centered |
| Section header | 13pt Regular (caption), uppercase, text-tertiary |
| Row label | 17pt Regular (body), text-primary |
| Row value | 17pt Semibold (body-emphasis), text-primary |
| Footer text | 13pt Regular (caption), text-tertiary |
| Footer quote | 11pt Regular Italic (caption-sm), text-tertiary |

### Spacing

- Screen horizontal padding: 24pt
- Section vertical spacing: 32pt
- Row vertical padding: 16pt
- Divider: 1pt height, full width minus 24pt leading padding

---

## Settings Structure & Behavior

### Section 1: YOUR LIFE

**Born**
- Display: User's birth date formatted as "Month DD, YYYY"
- Tap action: Present date picker sheet
- On change: Recalculate all week numbers, update grid

**Expected lifespan**
- Display: "XX years"
- Tap action: Present wheel picker (range: 60-120, default: 80)
- On change: Recalculate total weeks, update grid immediately
- Storage: `UserSettings.lifeExpectancy`

```swift
// Life expectancy picker
Picker("Expected lifespan", selection: $lifeExpectancy) {
    ForEach(60...120, id: \.self) { age in
        Text("\(age) years").tag(age)
    }
}
.pickerStyle(.wheel)
```

### Section 2: CHAPTERS

**Manage phases**
- Tap action: Navigate to PhaseManagerView (existing or create)
- Displays list of phases with edit/delete/reorder capability
- Chevron indicator (→)

### Section 3: REMINDERS

**Daily notification**
- Display: Time formatted as "H:MM AM/PM"
- Tap action: Present time picker
- On change: Reschedule notification
- Storage: `UserSettings.dailyNotificationTime`

**Milestone alerts**
- Display: "On" / "Off"
- Tap action: Toggle inline
- Storage: `UserSettings.milestoneAlertsEnabled`

### Section 4: DATA

**Export life grid**
- Tap action: Generate grid image, present share sheet
- Chevron indicator (→)
- Implementation: Render GridView to UIImage, UIActivityViewController

**Erase everything**
- Text color: Destructive red (#DC2626)
- Tap action: Present confirmation alert
- Chevron indicator (→)

```swift
// Erase confirmation
.alert("Erase Everything?", isPresented: $showEraseConfirmation) {
    Button("Cancel", role: .cancel) { }
    Button("Erase", role: .destructive) {
        eraseAllData()
    }
} message: {
    Text("This will delete all your life data including phases and marked weeks. This cannot be undone.")
}
```

### Footer

- App version: "finite v1.0" (or dynamic from bundle)
- Quote: "Hurry up and live." — Seneca
- Centered, at bottom of scroll view

---

## Implementation Approach

### Option A: Custom Layout (Recommended)

Build settings with plain SwiftUI views instead of Form/List:

```swift
struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var users: [User]
    
    var user: User? { users.first }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // YOUR LIFE section
                SettingsSection(title: "YOUR LIFE") {
                    SettingsRow(
                        label: "Born",
                        value: user?.birthDate.formatted(.dateTime.month().day().year()) ?? ""
                    ) {
                        // Present date picker
                    }
                    
                    SettingsRow(
                        label: "Expected lifespan",
                        value: "\(user?.settings.lifeExpectancy ?? 80) years"
                    ) {
                        // Present wheel picker
                    }
                }
                
                // CHAPTERS section
                SettingsSection(title: "CHAPTERS") {
                    SettingsNavigationRow(label: "Manage phases") {
                        PhaseManagerView()
                    }
                }
                
                // ... more sections
                
                // Footer
                VStack(spacing: 4) {
                    Text("finite v\(appVersion)")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                    Text(""Hurry up and live." — Seneca")
                        .font(.system(size: 11))
                        .italic()
                        .foregroundStyle(.tertiary)
                }
                .padding(.top, 24)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
        }
        .background(Color("bg-primary"))
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}
```

### Supporting Components

```swift
// Section container
struct SettingsSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.caption)
                .textCase(.uppercase)
                .foregroundStyle(.tertiary)
                .padding(.bottom, 12)
            
            VStack(spacing: 0) {
                content
            }
            .background(Color("bg-secondary"))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

// Standard row (tappable)
struct SettingsRow: View {
    let label: String
    let value: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(label)
                    .font(.body)
                    .foregroundStyle(Color("text-primary"))
                Spacer()
                Text(value)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(Color("text-primary"))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
        .buttonStyle(.plain)
    }
}

// Navigation row (with chevron)
struct SettingsNavigationRow<Destination: View>: View {
    let label: String
    @ViewBuilder let destination: Destination
    
    var body: some View {
        NavigationLink {
            destination
        } label: {
            HStack {
                Text(label)
                    .font(.body)
                    .foregroundStyle(Color("text-primary"))
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
    }
}

// Toggle row
struct SettingsToggleRow: View {
    let label: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            Text(label)
                .font(.body)
                .foregroundStyle(Color("text-primary"))
            Spacer()
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(Color("accent"))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

// Destructive row
struct SettingsDestructiveRow: View {
    let label: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(label)
                    .font(.body)
                    .foregroundStyle(Color(hex: "#DC2626"))
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color(hex: "#DC2626").opacity(0.6))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
        .buttonStyle(.plain)
    }
}
```

### Dividers Between Rows

Add dividers between rows within a section:

```swift
struct SettingsSection<Content: View>: View {
    // ...
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                // ...
            
            VStack(spacing: 0) {
                // Use ForEach with indices or manual dividers
                content
            }
            .background(Color("bg-secondary"))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

// Manual divider
struct SettingsDivider: View {
    var body: some View {
        Rectangle()
            .fill(Color("border"))
            .frame(height: 1)
            .padding(.leading, 16)
    }
}
```

---

## Data Model Updates

### Update UserSettings

```swift
// In User.swift or UserSettings.swift
@Model
class UserSettings {
    var dailyNotificationEnabled: Bool = true
    var dailyNotificationTime: Date = Calendar.current.date(from: DateComponents(hour: 8, minute: 0))!
    var currentViewMode: ViewMode = .focus
    var lifeExpectancy: Int = 80  // ← Ensure this exists and is editable
    var milestoneAlertsEnabled: Bool = true  // ← Add if not present
}
```

### Life Expectancy Change Handler

When life expectancy changes, the grid must update:

```swift
func updateLifeExpectancy(_ newValue: Int) {
    user.settings.lifeExpectancy = newValue
    
    // Grid recalculates automatically via computed properties:
    // - user.totalWeeks = lifeExpectancy * 52
    // - user.weeksRemaining = totalWeeks - currentWeekNumber
    
    // Trigger any necessary view updates
    // SwiftData should handle this automatically
    
    // Reschedule milestone notifications if needed
    NotificationService.shared.rescheduleMilestones(for: user)
}
```

---

## Sheet Presentations

### Life Expectancy Picker Sheet

```swift
struct LifeExpectancySheet: View {
    @Binding var lifeExpectancy: Int
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("How long do you expect to live?")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                
                Picker("Years", selection: $lifeExpectancy) {
                    ForEach(60...120, id: \.self) { age in
                        Text("\(age)").tag(age)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 150)
                
                Text("\(lifeExpectancy * 52) weeks")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.primary)
            }
            .padding(24)
            .navigationTitle("Expected Lifespan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}
```

### Birth Date Picker Sheet

```swift
struct BirthDateSheet: View {
    @Binding var birthDate: Date
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            DatePicker(
                "Birth Date",
                selection: $birthDate,
                in: ...Date(),
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .padding(24)
            .navigationTitle("Birth Date")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}
```

---

## Erase All Data

```swift
func eraseAllData() {
    // Delete all weeks
    let weekDescriptor = FetchDescriptor<Week>()
    if let weeks = try? modelContext.fetch(weekDescriptor) {
        weeks.forEach { modelContext.delete($0) }
    }
    
    // Delete all phases
    let phaseDescriptor = FetchDescriptor<LifePhase>()
    if let phases = try? modelContext.fetch(phaseDescriptor) {
        phases.forEach { modelContext.delete($0) }
    }
    
    // Reset user settings to defaults (keep birth date)
    if let user = users.first {
        user.settings.lifeExpectancy = 80
        user.settings.currentViewMode = .focus
        // Keep birth date - user would need to re-onboard to change
    }
    
    // Cancel all notifications
    NotificationService.shared.cancelAll()
    
    // Haptic feedback
    HapticService.shared.notification(.success)
    
    // Navigate back to grid
    dismiss()
}
```

---

## Export Life Grid (Optional for V1.0)

```swift
func exportGrid() {
    // Create a render of GridView at 2x scale
    let renderer = ImageRenderer(content: 
        GridView(user: user, isExportMode: true)
            .frame(width: 390, height: 844)
    )
    renderer.scale = 2.0
    
    if let image = renderer.uiImage {
        let activityVC = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        
        // Present share sheet
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
}
```

---

## Files to Modify/Create

### Modify
- `Features/Settings/SettingsView.swift` — Complete redesign
- `Core/Models/User.swift` or `UserSettings` — Ensure lifeExpectancy is editable

### Create (if needed)
- `Design/Components/SettingsSection.swift` — Reusable section component
- `Design/Components/SettingsRow.swift` — Reusable row components
- `Features/Settings/LifeExpectancySheet.swift` — Picker sheet
- `Features/Settings/BirthDateSheet.swift` — Date picker sheet
- `Features/Settings/PhaseManagerView.swift` — If doesn't exist

---

## Haptic Feedback

| Interaction | Haptic |
|-------------|--------|
| Tap any row | `.light` impact |
| Change value (picker) | Selection feedback |
| Toggle switch | `.light` impact |
| Erase confirmed | `.success` notification |
| Error | `.error` notification |

---

## Testing Checklist

- [ ] Birth date change recalculates week numbers
- [ ] Life expectancy change updates grid immediately
- [ ] Life expectancy range enforced (60-120)
- [ ] Notification time change reschedules notifications
- [ ] Milestone toggle enables/disables milestone notifications
- [ ] Erase everything clears all data
- [ ] Erase confirmation prevents accidental deletion
- [ ] Export generates correct image
- [ ] Dark mode appearance correct
- [ ] All rows have tap feedback
- [ ] Settings persists after app restart

---

## Philosophy Reminder

> Settings should feel like part of the contemplative experience, not an escape from it.

The act of setting your life expectancy IS a philosophical moment. Don't soften it. When a user picks "80 years," they're saying "I think I have this much time." That's profound.

Keep the design stark. No decoration. No explanation text. Just the choices and their consequences.