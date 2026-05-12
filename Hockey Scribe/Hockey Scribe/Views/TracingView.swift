import SwiftUI
import PencilKit
import AVFoundation
import UIKit

struct TracingView: View {
    @EnvironmentObject var appState: AppState
    let team: NHLTeam
    let word: String
    var headerImageURL: URL? = nil

    @State private var currentIndex = 0
    @State private var drawing = PKDrawing()
    @State private var strokeCountAtLetterStart = 0
    @State private var inactivityTimer: Timer?
    @State private var synthesizer = AVSpeechSynthesizer()
    @State private var completedIndices: Set<Int> = []

    private var letters: [Character] { Array(word) }
    private var currentLetter: Character { letters[currentIndex] }

    private var fontSize: CGFloat {
        let count = letters.count
        return max(90, 260 - CGFloat(count - 3) * 22)
    }

    private let phonics: [Character: String] = [
        "A": "ayy", "B": "buh", "C": "kuh", "D": "duh",
        "E": "eh",  "F": "fuh", "G": "guh", "H": "huh",
        "I": "ih",  "J": "juh", "K": "kuh", "L": "luh",
        "M": "muh", "N": "nuh", "O": "oh",  "P": "puh",
        "Q": "kwuh","R": "ruh", "S": "suh", "T": "tuh",
        "U": "uh",  "V": "vuh", "W": "wuh", "X": "ks",
        "Y": "yuh", "Z": "zuh"
    ]

    var body: some View {
        ZStack {
            team.primarySwiftUIColor.ignoresSafeArea()

            VStack(spacing: 0) {
                if let url = headerImageURL {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().scaledToFill()
                        default:
                            Color.clear
                        }
                    }
                    .frame(width: 720, height: 405)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .shadow(color: .black.opacity(0.35), radius: 12, y: 4)
                    .padding(.top, 36)
                } else {
                    Image(team.logoAssetName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 560, height: 560)
                        .padding(.top, 36)
                }

                Spacer()

                HStack(spacing: 8) {
                    ForEach(Array(letters.enumerated()), id: \.offset) { i, letter in
                        Text(String(letter))
                            .font(.custom("TeachingPrintDottedLined", size: fontSize))
                            .foregroundColor(letterColor(for: i))
                            .scaleEffect(i == currentIndex ? 1.08 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: currentIndex)
                            .animation(.easeInOut(duration: 0.3), value: completedIndices)
                    }
                }

                Spacer()

                Text("Trace the \(String(currentLetter))!")
                    .font(.system(size: 26, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.bottom, 48)
            }

            PencilKitCanvas(drawing: drawing) { newDrawing in
                drawing = newDrawing
                handleDrawingChange()
            }
            .ignoresSafeArea()
        }
        .onDisappear {
            inactivityTimer?.invalidate()
            synthesizer.stopSpeaking(at: .immediate)
        }
    }

    private func letterColor(for index: Int) -> Color {
        if completedIndices.contains(index) {
            return team.secondarySwiftUIColor
        } else if index == currentIndex {
            return .white
        } else {
            return .white.opacity(0.35)
        }
    }

    private func handleDrawingChange() {
        inactivityTimer?.invalidate()
        inactivityTimer = Timer.scheduledTimer(withTimeInterval: 1.2, repeats: false) { _ in
            DispatchQueue.main.async { checkCompletion() }
        }
    }

    private func checkCompletion() {
        let newStrokes = drawing.strokes.dropFirst(strokeCountAtLetterStart)
        let totalPoints = newStrokes.reduce(0) { $0 + $1.path.count }
        guard totalPoints > 20 else { return }

        inactivityTimer?.invalidate()
        speakPhonics(for: currentLetter)
        completedIndices.insert(currentIndex)

        let nextPhase: SessionPhase = appState.sessionPhase == .goalieTracing ? .goalCelebration : .celebration
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            if currentIndex + 1 < letters.count {
                strokeCountAtLetterStart = drawing.strokes.count
                currentIndex += 1
            } else {
                let screenSize = UIScreen.main.bounds.size
                appState.tracingSnapshot = drawing.image(
                    from: CGRect(origin: .zero, size: screenSize),
                    scale: UIScreen.main.scale
                )
                appState.sessionPhase = nextPhase
            }
        }
    }

    private func speakPhonics(for letter: Character) {
        let text = phonics[letter] ?? String(letter)
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = 0.38
        utterance.pitchMultiplier = 1.2
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        synthesizer.speak(utterance)
    }
}

#Preview {
    TracingView(team: allNHLTeams[0], word: allNHLTeams[0].nickname)
        .environmentObject(AppState())
}
