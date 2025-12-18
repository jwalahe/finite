# Copilot Task: Interactive Guided Walkthrough (V1.0 Feature)

## Overview

Finite needs a first-time user walkthrough that guides users through the core experience by having them **actually perform actions**, not just read about them. This creates muscle memory and ensures users understand the app before being left on their own.

**Design Philosophy:**
- Learn by doing, not reading
- Celebrate each completed action
- Never trap the user (skip always available)
- Feel like a guided meditation, not a tutorial

**Estimated Effort:** 8-12 days

---

## Walkthrough Flow

The walkthrough triggers **after the Reveal animation completes** (after the grid fills and current week starts pulsing). It consists of 7 steps:

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│  REVEAL ANIMATION COMPLETES                                     │
│              ↓                                                  │
│  Step 1: Grid Introduction         "This is your life in weeks" │
│              ↓ (tap anywhere)                                   │
│  Step 2: Current Week Spotlight    "This is where you are now"  │
│              ↓ (tap the pulsing week)                           │
│  Step 3: View Modes Introduction   "Swipe to see different views"│
│              ↓ (user swipes to Chapters)                        │
│  Step 4: Chapters Explanation      "Color your past with chapters"│
│              ↓ (tap anywhere)                                   │
│  Step 5: Add First Phase           Phase prompt modal appears   │
│              ↓ (user adds a phase OR skips)                     │
│  Step 6: Mark a Week               "Long-press to reflect"      │
│              ↓ (user long-presses and marks a week)             │
│  Step 7: Complete                  "You're ready"               │
│              ↓ (auto-dismiss after 2s)                          │
│                                                                 │
│  WALKTHROUGH COMPLETE → Normal app usage                        │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Architecture

### File Structure

```
Finite/
├── Core/
│   └── Services/
│       └── WalkthroughService.swift      # State machine, persistence
├── Design/
│   └── Components/
│       └── Walkthrough/
│           ├── WalkthroughOverlay.swift  # Main coordinator view
│           ├── SpotlightMask.swift       # Dimmed overlay with cutout
│           ├── CoachMark.swift           # Tooltip bubble
│           ├── GestureHint.swift         # Animated hand indicators
│           ├── PulseRing.swift           # Attention ring around elements
│           └── CelebrationBurst.swift    # Subtle success animation
└── Features/
    └── Grid/
        └── GridView.swift                # Integration point
```

### WalkthroughService (State Machine)

```swift
// Core/Services/WalkthroughService.swift

import SwiftUI
import Combine

enum WalkthroughStep: Int, CaseIterable, Identifiable {
    case gridIntro = 0
    case currentWeek = 1
    case viewModesIntro = 2
    case chaptersExplanation = 3
    case addPhase = 4
    case markWeek = 5
    case complete = 6
    
    var id: Int { rawValue }
    
    var title: String {
        switch self {
        case .gridIntro: return "Your Life in Weeks"
        case .currentWeek: return "You Are Here"
        case .viewModesIntro: return "Three Perspectives"
        case .chaptersExplanation: return "Life Chapters"
        case .addPhase: return "Add Your First Chapter"
        case .markWeek: return "Reflect on a Week"
        case .complete: return "You're Ready"
        }
    }
    
    var message: String {
        switch self {
        case .gridIntro: 
            return "Each dot is one week of your life.\nThe filled ones are behind you."
        case .currentWeek: 
            return "This glowing dot is today.\nTap it."
        case .viewModesIntro: 
            return "See your life through different lenses.\nSwipe left to try."
        case .chaptersExplanation: 
            return "Color your past by adding life chapters—school, career, adventures."
        case .addPhase: 
            return "Let's add your first chapter."
        case .markWeek: 
            return "Long-press any past week to record how it felt."
        case .complete: 
            return "Take your time. Reflect weekly.\nYour life is finite—make it count."
        }
    }
    
    var requiresUserAction: Bool {
        switch self {
        case .gridIntro, .chaptersExplanation: return false  // Tap anywhere
        case .currentWeek, .viewModesIntro, .addPhase, .markWeek: return true  // Specific action
        case .complete: return false  // Auto-dismiss
        }
    }
    
    var actionHint: String? {
        switch self {
        case .gridIntro: return "Tap anywhere to continue"
        case .currentWeek: return "Tap the glowing week"
        case .viewModesIntro: return "Swipe left on the grid"
        case .chaptersExplanation: return "Tap to continue"
        case .addPhase: return nil  // Modal handles this
        case .markWeek: return "Long-press any filled week"
        case .complete: return nil
        }
    }
}

@MainActor
class WalkthroughService: ObservableObject {
    // MARK: - Published State
    @Published var currentStep: WalkthroughStep?
    @Published var isActive: Bool = false
    @Published var showCelebration: Bool = false
    
    // MARK: - Persistence
    @AppStorage("hasCompletedWalkthrough") private var hasCompleted: Bool = false
    @AppStorage("walkthroughSkipped") private var wasSkipped: Bool = false
    
    // MARK: - Frame References (set by GridView)
    @Published var gridFrame: CGRect = .zero
    @Published var currentWeekFrame: CGRect = .zero
    @Published var dotIndicatorFrame: CGRect = .zero
    
    // MARK: - Computed
    var shouldShow: Bool {
        !hasCompleted && !wasSkipped
    }
    
    var canSkip: Bool {
        currentStep != .complete
    }
    
    var progress: Double {
        guard let step = currentStep else { return 0 }
        return Double(step.rawValue) / Double(WalkthroughStep.allCases.count - 1)
    }
    
    // MARK: - Lifecycle
    func startIfNeeded() {
        guard shouldShow else { return }
        
        // Delay start to let Reveal animation complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.isActive = true
            self?.currentStep = .gridIntro
            HapticService.shared.impact(.light)
        }
    }
    
    func advance() {
        guard let current = currentStep else { return }
        
        // Show celebration for action-based steps
        if current.requiresUserAction {
            triggerCelebration()
        }
        
        // Find next step
        guard let currentIndex = WalkthroughStep.allCases.firstIndex(of: current) else { return }
        let nextIndex = currentIndex + 1
        
        if nextIndex < WalkthroughStep.allCases.count {
            let nextStep = WalkthroughStep.allCases[nextIndex]
            
            // Slight delay between steps for breathing room
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                withAnimation(.easeOut(duration: 0.3)) {
                    self?.currentStep = nextStep
                }
                HapticService.shared.impact(.light)
            }
        } else {
            complete()
        }
    }
    
    func skip() {
        wasSkipped = true
        isActive = false
        currentStep = nil
        HapticService.shared.impact(.medium)
    }
    
    func complete() {
        hasCompleted = true
        
        // Show completion state briefly
        withAnimation(.easeOut(duration: 0.3)) {
            currentStep = .complete
        }
        
        // Auto-dismiss after 2.5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
            withAnimation(.easeOut(duration: 0.5)) {
                self?.isActive = false
                self?.currentStep = nil
            }
            HapticService.shared.notification(.success)
        }
    }
    
    func reset() {
        // For testing: reset walkthrough state
        hasCompleted = false
        wasSkipped = false
        currentStep = nil
        isActive = false
    }
    
    // MARK: - Private
    private func triggerCelebration() {
        showCelebration = true
        HapticService.shared.notification(.success)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            self?.showCelebration = false
        }
    }
}
```

---

## Component Specifications

### 1. WalkthroughOverlay (Main Coordinator)

```swift
// Design/Components/Walkthrough/WalkthroughOverlay.swift

import SwiftUI

struct WalkthroughOverlay: View {
    @ObservedObject var walkthrough: WalkthroughService
    let onPhasePrompt: () -> Void  // Triggers phase modal
    
    var body: some View {
        ZStack {
            // Dimmed background with spotlight cutout
            if let step = walkthrough.currentStep {
                SpotlightMask(
                    step: step,
                    gridFrame: walkthrough.gridFrame,
                    currentWeekFrame: walkthrough.currentWeekFrame,
                    dotIndicatorFrame: walkthrough.dotIndicatorFrame
                )
                .ignoresSafeArea()
                .allowsHitTesting(spotlightBlocksTouches(for: step))
                
                // Coach mark (tooltip)
                CoachMark(
                    step: step,
                    targetFrame: targetFrame(for: step),
                    onTap: handleTap
                )
                
                // Gesture hint (animated hand)
                if let gestureType = gestureType(for: step) {
                    GestureHint(
                        type: gestureType,
                        position: gesturePosition(for: step)
                    )
                }
                
                // Pulse ring around target
                if let targetFrame = spotlightFrame(for: step), step.requiresUserAction {
                    PulseRing(frame: targetFrame)
                }
                
                // Skip button
                if walkthrough.canSkip {
                    VStack {
                        HStack {
                            Spacer()
                            SkipButton {
                                walkthrough.skip()
                            }
                            .padding(.trailing, 24)
                            .padding(.top, 60)
                        }
                        Spacer()
                    }
                }
                
                // Progress indicator
                VStack {
                    Spacer()
                    ProgressDots(
                        totalSteps: WalkthroughStep.allCases.count - 1,  // Exclude .complete
                        currentStep: step.rawValue
                    )
                    .padding(.bottom, 40)
                }
            }
            
            // Celebration burst
            if walkthrough.showCelebration {
                CelebrationBurst()
            }
        }
        .animation(.easeOut(duration: 0.3), value: walkthrough.currentStep)
    }
    
    // MARK: - Helpers
    
    private func handleTap() {
        guard let step = walkthrough.currentStep else { return }
        
        switch step {
        case .gridIntro, .chaptersExplanation:
            // Tap anywhere advances
            walkthrough.advance()
            
        case .addPhase:
            // Trigger phase prompt modal
            onPhasePrompt()
            // Service will advance when phase is added or skipped
            
        default:
            // Other steps require specific user action
            break
        }
    }
    
    private func targetFrame(for step: WalkthroughStep) -> CGRect {
        switch step {
        case .gridIntro:
            return walkthrough.gridFrame
        case .currentWeek:
            return walkthrough.currentWeekFrame
        case .viewModesIntro:
            return walkthrough.dotIndicatorFrame
        case .chaptersExplanation:
            return walkthrough.gridFrame
        case .addPhase:
            return .zero  // Modal handles its own positioning
        case .markWeek:
            // Target a filled week (calculated dynamically)
            return walkthrough.currentWeekFrame.offsetBy(dx: -100, dy: -50)
        case .complete:
            return .zero
        }
    }
    
    private func spotlightFrame(for step: WalkthroughStep) -> CGRect? {
        switch step {
        case .currentWeek:
            return walkthrough.currentWeekFrame.insetBy(dx: -20, dy: -20)
        case .viewModesIntro:
            return walkthrough.dotIndicatorFrame.insetBy(dx: -30, dy: -20)
        case .markWeek:
            // Spotlight a region of filled weeks
            return walkthrough.currentWeekFrame.offsetBy(dx: -100, dy: -50).insetBy(dx: -40, dy: -40)
        default:
            return nil
        }
    }
    
    private func spotlightBlocksTouches(for step: WalkthroughStep) -> Bool {
        // Block touches on dimmed area for steps that require specific target
        switch step {
        case .currentWeek, .markWeek:
            return true
        default:
            return false
        }
    }
    
    private func gestureType(for step: WalkthroughStep) -> GestureHintType? {
        switch step {
        case .currentWeek: return .tap
        case .viewModesIntro: return .swipeLeft
        case .markWeek: return .longPress
        default: return nil
        }
    }
    
    private func gesturePosition(for step: WalkthroughStep) -> CGPoint {
        switch step {
        case .currentWeek:
            return CGPoint(
                x: walkthrough.currentWeekFrame.midX,
                y: walkthrough.currentWeekFrame.midY + 60
            )
        case .viewModesIntro:
            return CGPoint(
                x: walkthrough.gridFrame.midX,
                y: walkthrough.gridFrame.midY
            )
        case .markWeek:
            return CGPoint(
                x: walkthrough.currentWeekFrame.midX - 80,
                y: walkthrough.currentWeekFrame.midY
            )
        default:
            return .zero
        }
    }
}
```

### 2. SpotlightMask (Dimmed Overlay with Cutout)

```swift
// Design/Components/Walkthrough/SpotlightMask.swift

import SwiftUI

struct SpotlightMask: View {
    let step: WalkthroughStep
    let gridFrame: CGRect
    let currentWeekFrame: CGRect
    let dotIndicatorFrame: CGRect
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Full screen dim
                Color.black.opacity(dimOpacity)
                
                // Spotlight cutout (if applicable)
                if let spotlightRect = spotlightRect {
                    Color.black.opacity(dimOpacity)
                        .mask(
                            Canvas { context, size in
                                // Fill entire canvas
                                context.fill(
                                    Path(CGRect(origin: .zero, size: size)),
                                    with: .color(.white)
                                )
                                
                                // Cut out spotlight area
                                context.blendMode = .destinationOut
                                
                                let spotlightPath = Path(
                                    roundedRect: spotlightRect,
                                    cornerRadius: spotlightCornerRadius
                                )
                                context.fill(spotlightPath, with: .color(.white))
                            }
                        )
                } else {
                    Color.black.opacity(dimOpacity)
                }
            }
        }
        .animation(.easeOut(duration: 0.4), value: step)
    }
    
    // MARK: - Computed
    
    private var dimOpacity: Double {
        switch step {
        case .complete: return 0.85  // Darker for finale
        default: return 0.75
        }
    }
    
    private var spotlightRect: CGRect? {
        switch step {
        case .gridIntro:
            // Large spotlight on entire grid
            return gridFrame.insetBy(dx: -16, dy: -16)
            
        case .currentWeek:
            // Small spotlight on current week
            return currentWeekFrame.insetBy(dx: -24, dy: -24)
            
        case .viewModesIntro:
            // Spotlight on dot indicator + nearby grid area
            let indicatorSpotlight = dotIndicatorFrame.insetBy(dx: -40, dy: -20)
            let gridBottom = CGRect(
                x: gridFrame.minX,
                y: gridFrame.maxY - 100,
                width: gridFrame.width,
                height: 100
            )
            return indicatorSpotlight.union(gridBottom)
            
        case .chaptersExplanation:
            // Spotlight on grid (showing colors)
            return gridFrame.insetBy(dx: -16, dy: -16)
            
        case .markWeek:
            // Spotlight on a region of filled weeks
            let targetArea = CGRect(
                x: currentWeekFrame.minX - 120,
                y: currentWeekFrame.minY - 60,
                width: 160,
                height: 120
            )
            return targetArea
            
        case .addPhase, .complete:
            return nil  // No spotlight
        }
    }
    
    private var spotlightCornerRadius: CGFloat {
        switch step {
        case .currentWeek: return 50  // Circular for single week
        default: return 16
        }
    }
}
```

### 3. CoachMark (Tooltip Bubble)

```swift
// Design/Components/Walkthrough/CoachMark.swift

import SwiftUI

enum TooltipPosition {
    case above, below, left, right, center
}

struct CoachMark: View {
    let step: WalkthroughStep
    let targetFrame: CGRect
    let onTap: () -> Void
    
    @State private var isVisible = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 12) {
                // Title
                Text(step.title)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                
                // Message
                Text(step.message)
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                
                // Action hint
                if let hint = step.actionHint {
                    Text(hint)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                        .padding(.top, 8)
                }
            }
            .padding(24)
            .frame(maxWidth: 300)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .environment(\.colorScheme, .dark)
            )
            .position(tooltipPosition(in: geometry.size))
            .opacity(isVisible ? 1 : 0)
            .scaleEffect(isVisible ? 1 : 0.9)
            .onAppear {
                withAnimation(.easeOut(duration: 0.3).delay(0.1)) {
                    isVisible = true
                }
            }
            .onTapGesture {
                if !step.requiresUserAction {
                    onTap()
                }
            }
        }
    }
    
    private func tooltipPosition(in screenSize: CGSize) -> CGPoint {
        let position = calculatePosition(for: step, screenSize: screenSize)
        
        switch position {
        case .center:
            return CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)
        case .above:
            return CGPoint(
                x: targetFrame.midX,
                y: max(100, targetFrame.minY - 120)
            )
        case .below:
            return CGPoint(
                x: targetFrame.midX,
                y: min(screenSize.height - 100, targetFrame.maxY + 120)
            )
        default:
            return CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)
        }
    }
    
    private func calculatePosition(for step: WalkthroughStep, screenSize: CGSize) -> TooltipPosition {
        switch step {
        case .gridIntro: return .center
        case .currentWeek: return targetFrame.midY > screenSize.height / 2 ? .above : .below
        case .viewModesIntro: return .above
        case .chaptersExplanation: return .center
        case .addPhase: return .center
        case .markWeek: return targetFrame.midY > screenSize.height / 2 ? .above : .below
        case .complete: return .center
        }
    }
}
```

### 4. GestureHint (Animated Hand)

```swift
// Design/Components/Walkthrough/GestureHint.swift

import SwiftUI

enum GestureHintType {
    case tap
    case longPress
    case swipeLeft
    case swipeRight
    case swipeUp
}

struct GestureHint: View {
    let type: GestureHintType
    let position: CGPoint
    
    @State private var animationPhase: CGFloat = 0
    @State private var isVisible = false
    
    var body: some View {
        ZStack {
            // Hand/finger icon
            Image(systemName: handIcon)
                .font(.system(size: 32, weight: .light))
                .foregroundStyle(.white)
                .offset(animationOffset)
                .scaleEffect(animationScale)
                .opacity(isVisible ? 1 : 0)
        }
        .position(position)
        .onAppear {
            startAnimation()
        }
    }
    
    private var handIcon: String {
        switch type {
        case .tap, .longPress: return "hand.point.up.fill"
        case .swipeLeft, .swipeRight: return "hand.draw.fill"
        case .swipeUp: return "hand.point.up.fill"
        }
    }
    
    private var animationOffset: CGSize {
        switch type {
        case .tap:
            return CGSize(width: 0, height: animationPhase * -10)
        case .longPress:
            return CGSize(width: 0, height: animationPhase * -5)
        case .swipeLeft:
            return CGSize(width: -animationPhase * 60, height: 0)
        case .swipeRight:
            return CGSize(width: animationPhase * 60, height: 0)
        case .swipeUp:
            return CGSize(width: 0, height: -animationPhase * 40)
        }
    }
    
    private var animationScale: CGFloat {
        switch type {
        case .tap:
            return 1.0 - (animationPhase * 0.15)  // Press down effect
        case .longPress:
            return animationPhase > 0.5 ? 0.85 : 1.0  // Hold down
        default:
            return 1.0
        }
    }
    
    private func startAnimation() {
        withAnimation(.easeOut(duration: 0.3)) {
            isVisible = true
        }
        
        // Start gesture animation loop
        switch type {
        case .tap:
            withAnimation(.easeInOut(duration: 0.4).repeatForever(autoreverses: true).delay(0.5)) {
                animationPhase = 1
            }
        case .longPress:
            // Single press and hold
            withAnimation(.easeOut(duration: 0.3).delay(0.5)) {
                animationPhase = 1
            }
            // Release after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.easeOut(duration: 0.2)) {
                    animationPhase = 0
                }
                // Repeat
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    startAnimation()
                }
            }
        case .swipeLeft, .swipeRight, .swipeUp:
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: false).delay(0.3)) {
                animationPhase = 1
            }
        }
    }
}
```

### 5. PulseRing (Attention Indicator)

```swift
// Design/Components/Walkthrough/PulseRing.swift

import SwiftUI

struct PulseRing: View {
    let frame: CGRect
    
    @State private var scale: CGFloat = 1.0
    @State private var opacity: Double = 0.8
    
    var body: some View {
        ZStack {
            // Inner ring
            RoundedRectangle(cornerRadius: frame.width / 2)
                .stroke(Color.white.opacity(0.6), lineWidth: 2)
                .frame(width: frame.width, height: frame.height)
            
            // Outer pulsing ring
            RoundedRectangle(cornerRadius: frame.width / 2)
                .stroke(Color.white.opacity(opacity), lineWidth: 2)
                .frame(width: frame.width, height: frame.height)
                .scaleEffect(scale)
        }
        .position(x: frame.midX, y: frame.midY)
        .onAppear {
            withAnimation(.easeOut(duration: 1.2).repeatForever(autoreverses: false)) {
                scale = 1.6
                opacity = 0
            }
        }
    }
}
```

### 6. CelebrationBurst (Success Animation)

```swift
// Design/Components/Walkthrough/CelebrationBurst.swift

import SwiftUI

struct CelebrationBurst: View {
    @State private var particles: [Particle] = []
    @State private var isAnimating = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles) { particle in
                    Circle()
                        .fill(particle.color)
                        .frame(width: particle.size, height: particle.size)
                        .position(particle.position)
                        .opacity(particle.opacity)
                }
            }
            .onAppear {
                createParticles(in: geometry.size)
                animateParticles()
            }
        }
        .allowsHitTesting(false)
    }
    
    private func createParticles(in size: CGSize) {
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let colors: [Color] = [.white, .yellow, .cyan, .mint]
        
        particles = (0..<20).map { i in
            Particle(
                id: i,
                position: center,
                targetPosition: CGPoint(
                    x: center.x + CGFloat.random(in: -150...150),
                    y: center.y + CGFloat.random(in: -150...150)
                ),
                color: colors.randomElement()!,
                size: CGFloat.random(in: 4...10),
                opacity: 1.0
            )
        }
    }
    
    private func animateParticles() {
        withAnimation(.easeOut(duration: 0.6)) {
            for i in particles.indices {
                particles[i].position = particles[i].targetPosition
                particles[i].opacity = 0
            }
        }
    }
}

struct Particle: Identifiable {
    let id: Int
    var position: CGPoint
    let targetPosition: CGPoint
    let color: Color
    let size: CGFloat
    var opacity: Double
}
```

### 7. Supporting Components

```swift
// Skip Button
struct SkipButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("Skip")
                .font(.body)
                .foregroundStyle(.white.opacity(0.7))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(.white.opacity(0.15))
                )
        }
    }
}

// Progress Dots
struct ProgressDots: View {
    let totalSteps: Int
    let currentStep: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalSteps, id: \.self) { index in
                Circle()
                    .fill(index <= currentStep ? Color.white : Color.white.opacity(0.3))
                    .frame(width: 6, height: 6)
                    .scaleEffect(index == currentStep ? 1.2 : 1.0)
                    .animation(.snappy(duration: 0.2), value: currentStep)
            }
        }
    }
}
```

---

## Integration with GridView

```swift
// Features/Grid/GridView.swift

struct GridView: View {
    @StateObject private var walkthrough = WalkthroughService()
    @State private var showPhasePrompt = false
    
    // Frame tracking for walkthrough
    @State private var gridFrame: CGRect = .zero
    @State private var currentWeekFrame: CGRect = .zero
    @State private var dotIndicatorFrame: CGRect = .zero
    
    var body: some View {
        ZStack {
            // Main grid content
            mainGridContent
                .background(
                    GeometryReader { geo in
                        Color.clear.preference(
                            key: GridFrameKey.self,
                            value: geo.frame(in: .global)
                        )
                    }
                )
                .onPreferenceChange(GridFrameKey.self) { frame in
                    gridFrame = frame
                    walkthrough.gridFrame = frame
                }
            
            // Walkthrough overlay
            if walkthrough.isActive {
                WalkthroughOverlay(
                    walkthrough: walkthrough,
                    onPhasePrompt: {
                        showPhasePrompt = true
                    }
                )
                .transition(.opacity)
            }
        }
        .onAppear {
            // Start walkthrough after reveal
            walkthrough.startIfNeeded()
        }
        .sheet(isPresented: $showPhasePrompt) {
            PhaseFormView(
                mode: .add,
                user: user,
                onSave: { phase in
                    modelContext.insert(phase)
                    walkthrough.advance()  // Advance after phase added
                }
            )
            .onDisappear {
                // If user dismissed without adding, still advance
                if walkthrough.currentStep == .addPhase {
                    walkthrough.advance()
                }
            }
        }
        .onChange(of: viewMode) { _, newMode in
            // Detect when user swipes to different view
            if walkthrough.currentStep == .viewModesIntro && newMode == .chapters {
                walkthrough.advance()
            }
        }
        .onReceive(weekMarkedPublisher) { _ in
            // Detect when user marks a week
            if walkthrough.currentStep == .markWeek {
                walkthrough.advance()
            }
        }
    }
    
    // Track current week frame
    private var currentWeekCell: some View {
        WeekCell(...)
            .background(
                GeometryReader { geo in
                    Color.clear.preference(
                        key: CurrentWeekFrameKey.self,
                        value: geo.frame(in: .global)
                    )
                }
            )
            .onPreferenceChange(CurrentWeekFrameKey.self) { frame in
                currentWeekFrame = frame
                walkthrough.currentWeekFrame = frame
            }
    }
}

// Preference Keys for frame tracking
struct GridFrameKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

struct CurrentWeekFrameKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}
```

---

## Step-by-Step Behavior Details

### Step 1: Grid Introduction
- **Trigger:** Automatically after Reveal animation + 1.5s delay
- **Visual:** Full grid spotlighted, dimmed edges
- **Interaction:** Tap anywhere to continue
- **Haptic:** Light impact on entry

### Step 2: Current Week
- **Trigger:** After Step 1 tap
- **Visual:** Small spotlight on pulsing current week, animated tap hand below
- **Interaction:** User must tap the pulsing week
- **Haptic:** Light impact when tapping correct target
- **Celebration:** Burst animation on success

### Step 3: View Modes Introduction
- **Trigger:** After Step 2 success
- **Visual:** Spotlight on bottom grid area + dot indicator, swipe hand animation
- **Interaction:** User must swipe left to Chapters view
- **Haptic:** Light impact when swipe detected
- **Celebration:** Burst animation on success
- **Note:** Grid must respond to swipe normally during this step

### Step 4: Chapters Explanation
- **Trigger:** After user swipes to Chapters view
- **Visual:** Grid now showing phase colors (if any), tooltip explains chapters
- **Interaction:** Tap anywhere to continue
- **Haptic:** Light impact

### Step 5: Add First Phase
- **Trigger:** After Step 4 tap
- **Visual:** Dimmed screen, centered tooltip
- **Interaction:** Phase modal appears automatically
- **Flow:** User either adds a phase OR taps "Skip for now" in modal
- **Haptic:** Medium impact on phase save
- **Note:** Advance regardless of whether user adds phase or skips

### Step 6: Mark a Week
- **Trigger:** After Step 5 completion
- **Visual:** Spotlight on region of filled weeks, long-press hand animation
- **Interaction:** User must long-press any filled week
- **Flow:** Week detail sheet opens, user marks and saves
- **Haptic:** Medium impact on sheet open, Success notification on save
- **Celebration:** Burst animation on success

### Step 7: Complete
- **Trigger:** After Step 6 success
- **Visual:** Full dim, centered "You're ready" message
- **Interaction:** None - auto-dismisses after 2.5s
- **Haptic:** Success notification on dismiss

---

## Edge Cases

| Scenario | Handling |
|----------|----------|
| User taps Skip at any point | Walkthrough dismissed, flag set, never shows again |
| User backgrounds app during walkthrough | Resume from current step on return |
| User force-quits during walkthrough | Resume from current step on next launch |
| User has no filled weeks for Step 6 | Spotlight first few weeks of grid instead |
| User already has phases | Skip Step 5 (addPhase) |
| User rotates device | Frames recalculate via preference keys |
| User dismisses phase modal without action | Still advance to next step |

---

## Animation Timings

| Animation | Duration | Easing | Notes |
|-----------|----------|--------|-------|
| Step transition | 0.3s | `.easeOut` | Between steps |
| Spotlight change | 0.4s | `.easeOut` | Mask morph |
| Tooltip appear | 0.3s | `.easeOut` | With 0.1s delay |
| Gesture hint | varies | varies | Per gesture type |
| Pulse ring | 1.2s | `.easeOut` | Repeating |
| Celebration burst | 0.6s | `.easeOut` | Particles expand |
| Final dismiss | 0.5s | `.easeOut` | Fade out |

---

## Haptic Feedback

| Event | Haptic |
|-------|--------|
| Step entry | `.light` impact |
| User completes action | `.success` notification |
| Skip pressed | `.medium` impact |
| Walkthrough complete | `.success` notification |

---

## Testing Checklist

### Flow Testing
- [ ] Walkthrough starts after Reveal completes
- [ ] Each step displays correct content
- [ ] Tap-to-continue works on non-action steps
- [ ] Specific actions detected correctly (tap week, swipe, long-press)
- [ ] Skip button dismisses walkthrough
- [ ] Walkthrough never shows again after completion
- [ ] Walkthrough never shows again after skip

### Visual Testing
- [ ] Spotlight correctly highlights target areas
- [ ] Tooltips positioned correctly for all steps
- [ ] Gesture hints animate correctly
- [ ] Pulse ring visible on action steps
- [ ] Celebration burst plays on action completion
- [ ] Progress dots update correctly
- [ ] Dark mode appearance correct

### Edge Cases
- [ ] App backgrounding preserves state
- [ ] Device rotation recalculates frames
- [ ] Phase modal dismissal advances correctly
- [ ] Week marking detection works
- [ ] View mode swipe detection works

### Integration
- [ ] Grid remains interactive during walkthrough (for user actions)
- [ ] Frame preferences pass correctly
- [ ] WalkthroughService state management correct
- [ ] Persistence works (reset in Settings for testing)

---

## Settings Integration (Debug)

Add a debug option to reset walkthrough for testing:

```swift
// In SettingsView.swift (debug section, remove before release)

#if DEBUG
Section("Debug") {
    Button("Reset Walkthrough") {
        WalkthroughService().reset()
    }
}
#endif
```

---

## Files to Create

| File | Purpose |
|------|---------|
| `Core/Services/WalkthroughService.swift` | State machine, persistence |
| `Design/Components/Walkthrough/WalkthroughOverlay.swift` | Main coordinator |
| `Design/Components/Walkthrough/SpotlightMask.swift` | Dimmed overlay with cutout |
| `Design/Components/Walkthrough/CoachMark.swift` | Tooltip bubble |
| `Design/Components/Walkthrough/GestureHint.swift` | Animated hand |
| `Design/Components/Walkthrough/PulseRing.swift` | Attention ring |
| `Design/Components/Walkthrough/CelebrationBurst.swift` | Success particles |
| `Design/Components/Walkthrough/ProgressDots.swift` | Step indicator |
| `Design/Components/Walkthrough/SkipButton.swift` | Skip control |

## Files to Modify

| File | Changes |
|------|---------|
| `Features/Grid/GridView.swift` | Add walkthrough overlay, frame tracking, action detection |
| `Features/Settings/SettingsView.swift` | Add debug reset (optional) |

---

## Philosophy Reminder

> "Learn by doing, not reading."

The user should feel like they're discovering the app naturally, with gentle guidance—not being lectured. Each completed action reinforces muscle memory. By the end, they've already used every core feature at least once.

The walkthrough is not a tutorial. It's a guided first experience that respects the user's intelligence while ensuring they don't miss anything important.