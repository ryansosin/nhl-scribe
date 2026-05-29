//
//  Hockey_ScribeApp.swift
//  Hockey Scribe
//

import SwiftUI
import AVFoundation

@main
struct Hockey_ScribeApp: App {
    @StateObject private var appState = AppState()

    init() {
        // Configure once at launch so TTS and the YouTube embed share a
        // .playback session. Without this, WKWebView won't autoplay media
        // with sound on iOS 17+ — the video loads but never starts.
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
        try? AVAudioSession.sharedInstance().setActive(true)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
        }
    }
}
