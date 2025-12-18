# Copilot Task: Phase System Polish (Colors, Birthday, Edit Form)

## Context

Finite is a "life in weeks" mortality visualization app. We have three issues to address:

1. **Phase colors are limited** — Only 8 predefined colors, auto-assigned
2. **Birthday cannot be changed** — Locked after onboarding
3. **Edit Phase looks ugly** — Doesn't match the polished Add Chapter experience

This prompt addresses all three with a unified approach inspired by Things 3, Notion, and Apple Calendar.

**App Philosophy:**
- Stark over soft
- Craft over features  
- Ritual over utility

---

## Issue 1: Expanded Color Palette with User Selection

### Current State
- 8 predefined colors in `PhaseColorService.swift`
- Colors auto-assigned in order when phases are created
- No way for user to choose or change colors during creation

### Solution: Curated Palette + User Selection

Expand to 16 colors organized in a 4×4 grid. User selects color when creating/editing phases.

**Color Palette (16 colors):**

```swift
// PhaseColorService.swift or Colors.swift

enum PhaseColor: String, CaseIterable, Codable {
    // Row 1: Neutrals
    case warmGray = "#78716C"
    case stone = "#A8A29E"
    case slate = "#64748B"
    case zinc = "#71717A"
    
    // Row 2: Cool tones
    case indigo = "#6366F1"
    case violet = "#8B5CF6"
    case purple = "#A855F7"
    case fuchsia = "#D946EF"
    
    // Row 3: Warm tones
    case rose = "#F43F5E"
    case pink = "#EC4899"
    case orange = "#F97316"
    case amber = "#F59E0B"
    
    // Row 4: Nature tones
    case emerald = "#10B981"
    case teal = "#14B8A6"
    case cyan = "#06B6D4"
    case sky = "#0EA5E9"
    
    var color: Color {
        Color(hex: self.rawValue)
    }
    
    var name: String {
        switch self {
        case .warmGray: return "Warm Gray"
        case .stone: return "Stone"
        case .slate: return "Slate"
        case .zinc: return "Zinc"
        case .indigo: return "Indigo"
        case .violet: return "Violet"
        case .purple: return "Purple"
        case .fuchsia: return "Fuchsia"
        case .rose: return "Rose"
        case .pink: return "Pink"
        case .orange: return "Orange"
        case .amber: return "Amber"
        case .emerald: return "Emerald"
        case .teal: return "Teal"
        case .cyan: return "Cyan"
        case .sky: return "Sky"
        }
    }
}
```

### Color Picker Component

```swift
// Design/Components/PhaseColorPicker.swift

struct PhaseColorPicker: View {
    @Binding var selectedColor: PhaseColor
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 4)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Chapter color")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(PhaseColor.allCases, id: \.self) { color in
                    ColorSwatch(
                        color: color,
                        isSelected: selectedColor == color
                    ) {
                        withAnimation(.snappy(duration: 0.15)) {
                            selectedColor = color
                        }
                        HapticService.shared.impact(.light)
                    }
                }
            }
        }
    }
}

struct ColorSwatch: View {
    let color: PhaseColor
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(color.color)
                    .frame(width: 44, height: 44)
                
                if isSelected {
                    // White checkmark for selected state
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 1.1 : 1.0)
        .animation(.snappy(duration: 0.15), value: isSelected)
    }
}
```

**Visual specs:**
- Swatch size: 44pt diameter (tap target compliant)
- Grid spacing: 12pt
- Selected state: white checkmark + 1.1x scale
- Haptic: `.light` on selection

---

## Issue 2: Birthday Editing in Settings

### Current State
- Birthday set during onboarding, cannot be changed
- Settings screen doesn't include birthday editing

### Solution: Add Birthday Row to Settings

**In SettingsView.swift**, under "YOUR LIFE" section:

```swift
// YOUR LIFE section
SettingsSection(title: "YOUR LIFE") {
    // Born row
    SettingsRow(
        label: "Born",
        value: user.birthDate.formatted(.dateTime.month().day().year())
    ) {
        showBirthdaySheet = true
    }
    
    SettingsDivider()
    
    // Expected lifespan row
    SettingsRow(
        label: "Expected lifespan",
        value: "\(user.settings.lifeExpectancy) years"
    ) {
        showLifeExpectancySheet = true
    }
}
.sheet(isPresented: $showBirthdaySheet) {
    BirthDateSheet(birthDate: $user.birthDate)
}
```

**Birthday Sheet:**

```swift
// Features/Settings/BirthDateSheet.swift

struct BirthDateSheet: View {
    @Binding var birthDate: Date
    @Environment(\.dismiss) private var dismiss
    @State private var tempDate: Date
    
    init(birthDate: Binding<Date>) {
        self._birthDate = birthDate
        self._tempDate = State(initialValue: birthDate.wrappedValue)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("When were you born?")
                    .font(.body)
                    .foregroundStyle(.secondary)
                
                DatePicker(
                    "Birth Date",
                    selection: $tempDate,
                    in: ...Date(),
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .labelsHidden()
                
                // Show impact preview
                VStack(spacing: 4) {
                    let weeksLived = calculateWeeksLived(from: tempDate)
                    Text("\(weeksLived.formatted()) weeks lived")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(24)
            .navigationTitle("Birth Date")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        birthDate = tempDate
                        HapticService.shared.impact(.medium)
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
    
    private func calculateWeeksLived(from date: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.weekOfYear], from: date, to: Date())
        return max(0, (components.weekOfYear ?? 0) + 1)
    }
}
```

**Behavior on birthday change:**
- All week numbers recalculate automatically (via computed properties)
- Grid updates immediately
- Phases stay at their week numbers (which now represent different calendar dates)
- No confirmation needed—just save

---

## Issue 3: Unified Phase Form (Add & Edit)

### Current State
- `PhaseBuilderView.swift` — polished Add Chapter experience
- `PhaseEditView.swift` — separate, less polished Edit experience

### Solution: Single `PhaseFormView` Used by Both

Create one form component that handles both add and edit modes.

```swift
// Features/Phases/PhaseFormView.swift

enum PhaseFormMode {
    case add
    case edit(LifePhase)
}

struct PhaseFormView: View {
    let mode: PhaseFormMode
    let user: User
    let onSave: (LifePhase) -> Void
    let onDelete: (() -> Void)?  // nil for add mode
    
    @Environment(\.dismiss) private var dismiss
    @State private var name: String
    @State private var startYear: Int
    @State private var endYear: Int
    @State private var rating: Int?
    @State private var selectedColor: PhaseColor
    @State private var showDeleteConfirmation = false
    
    // Computed properties
    private var isEditMode: Bool {
        if case .edit = mode { return true }
        return false
    }
    
    private var navigationTitle: String {
        isEditMode ? "Edit Chapter" : "Add Chapter"
    }
    
    private var saveButtonTitle: String {
        isEditMode ? "Save Changes" : "Add Chapter"
    }
    
    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        startYear <= endYear &&
        startYear >= user.birthYear &&
        endYear <= Calendar.current.component(.year, from: Date())
    }
    
    // Initializer
    init(mode: PhaseFormMode, user: User, onSave: @escaping (LifePhase) -> Void, onDelete: (() -> Void)? = nil) {
        self.mode = mode
        self.user = user
        self.onSave = onSave
        self.onDelete = onDelete
        
        // Initialize state based on mode
        switch mode {
        case .add:
            _name = State(initialValue: "")
            _startYear = State(initialValue: Calendar.current.component(.year, from: Date()) - 5)
            _endYear = State(initialValue: Calendar.current.component(.year, from: Date()))
            _rating = State(initialValue: nil)
            _selectedColor = State(initialValue: .indigo)  // Default color
        case .edit(let phase):
            _name = State(initialValue: phase.name)
            _startYear = State(initialValue: phase.startYear)
            _endYear = State(initialValue: phase.endYear)
            _rating = State(initialValue: phase.defaultRating)
            _selectedColor = State(initialValue: PhaseColor(rawValue: phase.colorHex) ?? .indigo)
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Grid preview
                    PhaseGridPreview(
                        user: user,
                        startYear: startYear,
                        endYear: endYear,
                        color: selectedColor.color
                    )
                    .frame(height: 120)
                    
                    Divider()
                    
                    // Chapter name
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Chapter name")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        TextField("e.g., College, Career, Travel Year", text: $name)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    // Year pickers
                    HStack(spacing: 24) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("From")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            YearWheelPicker(
                                selectedYear: $startYear,
                                range: user.birthYear...Calendar.current.component(.year, from: Date())
                            )
                            .frame(height: 120)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("To")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            YearWheelPicker(
                                selectedYear: $endYear,
                                range: user.birthYear...Calendar.current.component(.year, from: Date())
                            )
                            .frame(height: 120)
                        }
                    }
                    
                    // Color picker
                    PhaseColorPicker(selectedColor: $selectedColor)
                    
                    // Rating (optional)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("How was it overall? (optional)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        PhaseRatingPicker(rating: $rating)
                    }
                    
                    // Primary action button
                    Button(action: savePhase) {
                        Text(saveButtonTitle)
                            .font(.body.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(isValid ? Color.accentColor : Color.gray.opacity(0.3))
                            .foregroundStyle(isValid ? .white : .secondary)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(!isValid)
                    
                    // Delete button (edit mode only)
                    if isEditMode, let onDelete = onDelete {
                        Button(action: { showDeleteConfirmation = true }) {
                            Text("Delete Chapter")
                                .font(.body)
                                .foregroundStyle(Color(hex: "#DC2626"))
                        }
                        .padding(.top, 8)
                    }
                }
                .padding(24)
            }
            .background(Color("bg-primary"))
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Delete Chapter?", isPresented: $showDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    onDelete?()
                    dismiss()
                }
            } message: {
                Text("This will remove "\(name)" from your life chapters. This cannot be undone.")
            }
        }
    }
    
    private func savePhase() {
        var phase: LifePhase
        
        switch mode {
        case .add:
            phase = LifePhase(name: name, startYear: startYear, endYear: endYear)
        case .edit(let existingPhase):
            phase = existingPhase
            phase.name = name
            phase.startYear = startYear
            phase.endYear = endYear
        }
        
        phase.defaultRating = rating
        phase.colorHex = selectedColor.rawValue
        
        HapticService.shared.impact(.medium)
        onSave(phase)
        dismiss()
    }
}
```

### Usage

**Add Chapter (from PhasePromptModal or Settings):**
```swift
.sheet(isPresented: $showAddPhase) {
    PhaseFormView(
        mode: .add,
        user: user,
        onSave: { phase in
            modelContext.insert(phase)
        }
    )
}
```

**Edit Chapter (from Phase Manager or Settings):**
```swift
.sheet(item: $selectedPhase) { phase in
    PhaseFormView(
        mode: .edit(phase),
        user: user,
        onSave: { updatedPhase in
            // SwiftData handles updates automatically
        },
        onDelete: {
            modelContext.delete(phase)
        }
    )
}
```

### Supporting Components

**Phase Rating Picker:**
```swift
struct PhaseRatingPicker: View {
    @Binding var rating: Int?
    
    var body: some View {
        HStack(spacing: 16) {
            ForEach(1...5, id: \.self) { value in
                Button {
                    withAnimation(.snappy(duration: 0.15)) {
                        if rating == value {
                            rating = nil  // Deselect
                        } else {
                            rating = value
                        }
                    }
                    HapticService.shared.selection()
                } label: {
                    Circle()
                        .fill(rating == value ? ratingColor(value) : Color("bg-tertiary"))
                        .frame(width: 40, height: 40)
                        .overlay {
                            Text("\(value)")
                                .font(.body.weight(.medium))
                                .foregroundStyle(rating == value ? .white : .secondary)
                        }
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    private func ratingColor(_ value: Int) -> Color {
        switch value {
        case 1: return Color(hex: "#DC2626")
        case 2: return Color(hex: "#EA580C")
        case 3: return Color(hex: "#D97706")
        case 4: return Color(hex: "#65A30D")
        case 5: return Color(hex: "#16A34A")
        default: return Color.gray
        }
    }
}
```

**Phase Grid Preview:**
```swift
struct PhaseGridPreview: View {
    let user: User
    let startYear: Int
    let endYear: Int
    let color: Color
    
    var body: some View {
        // Simplified grid showing phase highlight
        // Reuse existing grid rendering logic but miniaturized
        GeometryReader { geometry in
            // ... render mini grid with selected years highlighted
        }
    }
}
```

---

## Data Model Updates

### Update LifePhase

Ensure `colorHex` is stored and used:

```swift
// Core/Models/LifePhase.swift

@Model
class LifePhase {
    var id: UUID
    var name: String
    var startYear: Int
    var endYear: Int
    var defaultRating: Int?
    var colorHex: String  // Store hex string, convert to PhaseColor when needed
    var createdAt: Date
    var sortOrder: Int
    
    init(name: String, startYear: Int, endYear: Int) {
        self.id = UUID()
        self.name = name
        self.startYear = startYear
        self.endYear = endYear
        self.colorHex = PhaseColor.indigo.rawValue  // Default
        self.createdAt = Date()
        self.sortOrder = 0
    }
    
    var color: Color {
        PhaseColor(rawValue: colorHex)?.color ?? Color.gray
    }
}
```

---

## Files to Modify

### New Files
- `Design/Components/PhaseColorPicker.swift`
- `Design/Components/PhaseRatingPicker.swift`
- `Features/Phases/PhaseFormView.swift` (unified form)
- `Features/Settings/BirthDateSheet.swift`

### Modified Files
- `Core/Services/PhaseColorService.swift` — Expand to 16 colors, add PhaseColor enum
- `Design/Colors.swift` — Add new color definitions if not using enum
- `Core/Models/LifePhase.swift` — Ensure colorHex property exists
- `Features/Settings/SettingsView.swift` — Add birthday row
- `Features/Phases/PhaseBuilderView.swift` — Replace with PhaseFormView usage
- `Features/Phases/PhaseEditView.swift` — Replace with PhaseFormView usage (or delete)

### Delete (if consolidating)
- `Features/Phases/PhaseEditView.swift` — Replaced by PhaseFormView

---

## Haptic Feedback

| Interaction | Haptic |
|-------------|--------|
| Color swatch tap | `.light` impact |
| Rating dot tap | Selection feedback |
| Save phase | `.medium` impact |
| Delete phase | `.success` notification |
| Year wheel scroll | Selection feedback (existing) |

---

## Animation Specs

| Animation | Duration | Easing |
|-----------|----------|--------|
| Color swatch scale | 0.15s | `.snappy` |
| Rating dot fill | 0.15s | `.snappy` |
| Grid preview update | 0.2s | `.easeOut` |
| Delete confirmation | System default | — |

---

## Testing Checklist

### Color Picker
- [ ] All 16 colors render correctly
- [ ] Tap selects color with checkmark
- [ ] Only one color selected at a time
- [ ] Selected color scales up 1.1x
- [ ] Haptic on selection
- [ ] Color persists after save
- [ ] Color displays correctly in grid (Chapters view)

### Birthday Editing
- [ ] Birthday row appears in Settings
- [ ] Tapping opens date picker sheet
- [ ] Date picker limits to past dates only
- [ ] Cancel dismisses without saving
- [ ] Save updates birthday
- [ ] Grid recalculates weeks after change
- [ ] Phases stay intact (week numbers shift to new dates)

### Unified Phase Form
- [ ] Add mode: empty fields, "Add Chapter" button
- [ ] Edit mode: pre-populated fields, "Save Changes" button
- [ ] Edit mode: Delete button visible
- [ ] Delete confirmation appears
- [ ] Validation prevents empty name
- [ ] Validation prevents end year < start year
- [ ] Year pickers respect birth year minimum
- [ ] Color picker integrated and functional
- [ ] Rating picker is optional (can be nil)
- [ ] Grid preview updates as years change
- [ ] Save creates/updates phase correctly

---

## Design Philosophy Alignment

These changes follow the **Things 3 / Notion pattern**:

1. **Curated choices** — 16 colors, not infinite. Constraints breed creativity.
2. **Visual selection** — Tap to select, see immediately. No dropdowns.
3. **Unified forms** — Same component for add and edit. Consistency is trust.
4. **Destructive actions separated** — Delete at bottom, requires confirmation.
5. **No unnecessary confirmation** — Edits save directly. Only confirm destruction.

> "The best interface is the one you've already learned."

By using the same form for add and edit, users learn once and apply everywhere.