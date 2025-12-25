//
//  MortalityVoice.swift
//  Finite
//
//  Death Voice - AVSpeechSynthesizer wrapper for "The Observer"
//  Philosophy: Death is not your enemy. Death is your witness.
//

import AVFoundation
import UIKit

class MortalityVoice: NSObject, ObservableObject {
    static let shared = MortalityVoice()

    private let synthesizer = AVSpeechSynthesizer()
    @Published private(set) var isSpeaking: Bool = false
    @Published private(set) var selectedVoiceName: String = "Default"
    private var completionHandler: (() -> Void)?
    private var cachedVoice: AVSpeechSynthesisVoice?

    // Death persona voice parameters - tuned for more natural sound
    // These values work better with premium/enhanced voices
    private struct DeathPersona {
        static let pitch: Float = 0.85        // Slightly lower, but not unnatural
        static let rate: Float = 0.48         // Slower than default, but not robotic
        static let volume: Float = 0.95       // Clear and present
        static let preDelay: TimeInterval = 0.6
        static let postDelay: TimeInterval = 0.3
    }

    override init() {
        super.init()
        synthesizer.delegate = self
        configureAudioSession()
        // Pre-select voice on init
        cachedVoice = selectBestVoice()
        selectedVoiceName = cachedVoice?.name ?? "Default"
    }

    // MARK: - Audio Session

    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                options: [.mixWithOthers, .duckOthers]
            )
        } catch {
            print("MortalityVoice: Audio session configuration failed: \(error)")
        }
    }

    // MARK: - Public API

    func speak(_ text: String, completion: (() -> Void)? = nil) {
        // Don't speak if VoiceOver is running - use accessibility announcement instead
        if UIAccessibility.isVoiceOverRunning {
            UIAccessibility.post(notification: .announcement, argument: text)
            completion?()
            return
        }

        // Stop any current speech
        synthesizer.stopSpeaking(at: .immediate)

        // Activate audio session
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("MortalityVoice: Failed to activate audio session: \(error)")
        }

        // Add natural pauses using punctuation
        let naturalText = addNaturalPauses(text)

        // Create utterance with Death persona parameters
        let utterance = AVSpeechUtterance(string: naturalText)
        utterance.pitchMultiplier = DeathPersona.pitch
        utterance.rate = DeathPersona.rate
        utterance.volume = DeathPersona.volume
        utterance.preUtteranceDelay = DeathPersona.preDelay
        utterance.postUtteranceDelay = DeathPersona.postDelay

        // Use cached voice or select new one
        utterance.voice = cachedVoice ?? selectBestVoice()

        self.completionHandler = completion
        self.isSpeaking = true
        synthesizer.speak(utterance)
    }

    func stop() {
        synthesizer.stopSpeaking(at: .word)
        isSpeaking = false
    }

    /// Refresh voice selection (call after user downloads new voices)
    func refreshVoice() {
        cachedVoice = selectBestVoice()
        selectedVoiceName = cachedVoice?.name ?? "Default"
    }

    // MARK: - Natural Speech

    /// Add subtle pauses for more natural speech rhythm
    private func addNaturalPauses(_ text: String) -> String {
        var result = text

        // Add micro-pauses after commas (already natural)
        // Add slightly longer pauses after periods
        result = result.replacingOccurrences(of: ". ", with: "...  ")

        // Add pause before dramatic words
        let dramaticWords = ["Death", "Time", "I noticed", "I watched", "I was there"]
        for word in dramaticWords {
            result = result.replacingOccurrences(of: word, with: "... \(word)")
        }

        // Clean up any triple+ ellipses
        while result.contains("....") {
            result = result.replacingOccurrences(of: "....", with: "...")
        }

        return result
    }

    // MARK: - Voice Selection

    /// Select the best available voice for the Death persona
    /// Priority: Premium > Enhanced > Default
    /// Preference: Deep male voices (Aaron, Daniel, Oliver)
    private func selectBestVoice() -> AVSpeechSynthesisVoice? {
        let available = AVSpeechSynthesisVoice.speechVoices()

        // Log available voices for debugging (only in debug builds)
        #if DEBUG
        logAvailableVoices(available)
        #endif

        // Priority 1: Premium voices (best quality, user must download)
        let premiumIdentifiers = [
            "com.apple.voice.premium.en-US.Zoe",      // Premium Zoe - very natural
            "com.apple.voice.premium.en-GB.Malcolm",  // Premium Malcolm - dignified
            "com.apple.voice.premium.en-US.Evan",     // Premium Evan
            "com.apple.voice.premium.en-AU.Lee",      // Premium Lee
            "com.apple.voice.premium.en-GB.Oliver"    // Premium Oliver
        ]

        for identifier in premiumIdentifiers {
            if let voice = available.first(where: { $0.identifier == identifier }) {
                print("MortalityVoice: Using premium voice: \(voice.name)")
                return voice
            }
        }

        // Priority 2: Enhanced voices (good quality, smaller download)
        let enhancedIdentifiers = [
            "com.apple.voice.enhanced.en-GB.Daniel",   // Enhanced Daniel - calm, British
            "com.apple.voice.enhanced.en-US.Evan",     // Enhanced Evan
            "com.apple.voice.enhanced.en-AU.Lee",      // Enhanced Lee
            "com.apple.voice.enhanced.en-GB.Oliver",   // Enhanced Oliver
            "com.apple.voice.enhanced.en-US.Tom",      // Enhanced Tom
            "com.apple.voice.enhanced.en-US.Aaron"     // Enhanced Aaron
        ]

        for identifier in enhancedIdentifiers {
            if let voice = available.first(where: { $0.identifier == identifier }) {
                print("MortalityVoice: Using enhanced voice: \(voice.name)")
                return voice
            }
        }

        // Priority 3: Any enhanced English voice
        if let enhancedVoice = available.first(where: {
            $0.identifier.contains("enhanced") && $0.language.hasPrefix("en")
        }) {
            print("MortalityVoice: Using enhanced voice: \(enhancedVoice.name)")
            return enhancedVoice
        }

        // Priority 4: Compact voices by name (these are the defaults)
        let preferredNames = ["Daniel", "Oliver", "Evan", "Lee", "Aaron", "Tom"]
        let englishVoices = available.filter { $0.language.hasPrefix("en") }

        for name in preferredNames {
            if let voice = englishVoices.first(where: { $0.name == name }) {
                print("MortalityVoice: Using compact voice: \(voice.name)")
                return voice
            }
        }

        // Ultimate fallback
        print("MortalityVoice: Using system default voice")
        return AVSpeechSynthesisVoice(language: "en-US")
    }

    #if DEBUG
    private func logAvailableVoices(_ voices: [AVSpeechSynthesisVoice]) {
        let englishVoices = voices.filter { $0.language.hasPrefix("en") }
        print("MortalityVoice: Available English voices (\(englishVoices.count)):")
        for voice in englishVoices.sorted(by: { $0.name < $1.name }) {
            let quality = voice.identifier.contains("premium") ? "★★★" :
                          voice.identifier.contains("enhanced") ? "★★" : "★"
            print("  \(quality) \(voice.name) [\(voice.identifier)]")
        }
    }
    #endif

    // MARK: - Preview

    func speakPreview() {
        let previewScripts = [
            "I am patient. I am inevitable. I am counting.",
            "The grid is not empty weeks until you die. It is full weeks you get to design.",
            "Death is not your enemy. Death is your witness."
        ]
        speak(previewScripts.randomElement()!)
    }

    /// List available premium voices for UI
    func availablePremiumVoices() -> [String] {
        let available = AVSpeechSynthesisVoice.speechVoices()
        return available
            .filter { $0.language.hasPrefix("en") && $0.identifier.contains("premium") }
            .map { $0.name }
            .sorted()
    }

    /// Check if any enhanced/premium voices are available
    var hasEnhancedVoice: Bool {
        guard let voice = cachedVoice else { return false }
        return voice.identifier.contains("enhanced") || voice.identifier.contains("premium")
    }
}

// MARK: - AVSpeechSynthesizerDelegate

extension MortalityVoice: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isSpeaking = false
            self.completionHandler?()
            self.completionHandler = nil
        }

        // Deactivate audio session
        do {
            try AVAudioSession.sharedInstance().setActive(
                false,
                options: .notifyOthersOnDeactivation
            )
        } catch {
            print("MortalityVoice: Failed to deactivate audio session: \(error)")
        }
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isSpeaking = false
            self.completionHandler = nil
        }
    }
}
