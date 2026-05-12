//
//  Hockey_ScribeApp.swift
//  Hockey Scribe
//

import SwiftUI

@main
struct Hockey_ScribeApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
        }
    }
}
