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
    private var completionHandler: (() -> Void)?

    // Death persona voice parameters - calm, slow, deliberate
    private struct DeathPersona {
        static let pitch: Float = 0.70        // Deep tone
        static let rate: Float = 0.42         // Slow, deliberate
        static let volume: Float = 0.90       // Clear but not jarring
        static let preDelay: TimeInterval = 0.8
        static let postDelay: TimeInterval = 0.5
    }

    override init() {
        super.init()
        synthesizer.delegate = self
        configureAudioSession()
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

        // Create utterance with Death persona parameters
        let utterance = AVSpeechUtterance(string: text)
        utterance.pitchMultiplier = DeathPersona.pitch
        utterance.rate = DeathPersona.rate
        utterance.volume = DeathPersona.volume
        utterance.preUtteranceDelay = DeathPersona.preDelay
        utterance.postUtteranceDelay = DeathPersona.postDelay

        // Select the best available voice
        utterance.voice = selectVoice()

        self.completionHandler = completion
        self.isSpeaking = true
        synthesizer.speak(utterance)
    }

    func stop() {
        synthesizer.stopSpeaking(at: .word)
        isSpeaking = false
    }

    // MARK: - Voice Selection

    private func selectVoice() -> AVSpeechSynthesisVoice? {
        // Priority order for "Death" voice - prefer deep, male voices
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

        // Fallback: try to find any voice with a deep-sounding name
        let deepVoiceNames = ["Aaron", "Daniel", "Tom", "Alex", "Fred"]
        let englishVoices = available.filter { $0.language.hasPrefix("en") }

        for name in deepVoiceNames {
            if let voice = englishVoices.first(where: { $0.name.contains(name) }) {
                return voice
            }
        }

        // Ultimate fallback to default English
        return AVSpeechSynthesisVoice(language: "en-US")
    }

    // MARK: - Preview

    func speakPreview() {
        let previewScripts = [
            "I am patient. I am inevitable. I am counting.",
            "The grid is not empty weeks until you die. It is full weeks you get to design.",
            "Death is not your enemy. Death is your witness."
        ]
        speak(previewScripts.randomElement()!)
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
