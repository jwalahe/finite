//
//  AudioService.swift
//  Finite
//
//  Created by Jwala Kompalli on 12/15/25.
//

import AVFoundation
import UIKit

final class AudioService {
    static let shared = AudioService()

    private var audioPlayer: AVAudioPlayer?

    private init() {
        configureAudioSession()
    }

    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to configure audio session: \(error)")
        }
    }

    /// Play the pencil/sketch sound for reveal animation
    /// Currently uses system sound as placeholder - replace with custom sound later
    func playPencilTick() {
        // System sound ID 1104 is a subtle tick sound
        // Replace this with custom pencil_fill.mp3 when available
        AudioServicesPlaySystemSound(1104)
    }

    /// Play a subtle tap sound
    func playTap() {
        AudioServicesPlaySystemSound(1105)
    }

    /// Play custom sound from bundle
    func playSound(named filename: String, withExtension ext: String = "mp3") {
        guard let url = Bundle.main.url(forResource: filename, withExtension: ext) else {
            print("Sound file not found: \(filename).\(ext)")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("Failed to play sound: \(error)")
        }
    }
}
