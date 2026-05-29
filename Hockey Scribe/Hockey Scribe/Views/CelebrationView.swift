import SwiftUI
import AVFoundation

struct CelebrationView: View {
    @EnvironmentObject var appState: AppState
    let team: NHLTeam

    @State private var goalScale: CGFloat = 0.1
    @State private var goalOpacity: Double = 0
    @State private var showConfetti = false
    @State private var synthesizer = AVSpeechSynthesizer()
    @State private var autoAdvanceWork: DispatchWorkItem?

    var body: some View {
        ZStack {
            team.primarySwiftUIColor.ignoresSafeArea()

            if showConfetti {
                ConfettiLayer(primary: team.secondarySwiftUIColor, secondary: .white)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }

            VStack(spacing: 0) {
                Spacer()

                Text("GOAL!")
                    .font(.system(size: 120, weight: .black, design: .rounded))
                    .foregroundColor(team.secondarySwiftUIColor)
                    .shadow(color: team.secondarySwiftUIColor.opacity(0.6), radius: 24, y: 0)
                    .scaleEffect(goalScale)
                    .opacity(goalOpacity)

                Spacer().frame(height: 24)

                if let snapshot = appState.tracingSnapshot {
                    Image(uiImage: snapshot)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: 640)
                        .padding(.horizontal, 32)
                        .opacity(goalOpacity)
                }

                Spacer().frame(height: 20)

                Text(celebrationLine)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .opacity(goalOpacity)

                Spacer()
            }
        }
        .onAppear {
            showConfetti = true
            withAnimation(.spring(response: 0.45, dampingFraction: 0.5)) {
                goalScale = 1.0
                goalOpacity = 1.0
            }
            speakCelebration()
            let work = DispatchWorkItem { advance() }
            autoAdvanceWork = work
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.5, execute: work)
        }
        .onDisappear {
            autoAdvanceWork?.cancel()
            synthesizer.stopSpeaking(at: .immediate)
        }
    }

    private func advance() {
        switch appState.sessionPhase {
        case .celebration:
            appState.sessionPhase = .goalie
        case .goalCelebration:
            appState.sessionPhase = .scorers
        default:
            appState.sessionPhase = .goalHorn
        }
    }

    private var celebrationLine: String {
        switch appState.sessionPhase {
        case .goalCelebration:
            return "Kick save by \(appState.childName), and a beauty!"
        case .scorerCelebration:
            return "Top shelf by \(appState.childName), what a snipe!"
        default:
            return "Shot by \(appState.childName), he scores!"
        }
    }

    private func speakCelebration() {
        let utterance = AVSpeechUtterance(string: celebrationLine)
        utterance.rate = 0.44
        utterance.pitchMultiplier = 1.25
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            synthesizer.speak(utterance)
        }
    }
}

private struct ConfettiLayer: View {
    let primary: Color
    let secondary: Color

    var body: some View {
        GeometryReader { geo in
            ForEach(0..<60, id: \.self) { i in
                ConfettiPiece(
                    color: i.isMultiple(of: 2) ? primary : secondary,
                    startX: CGFloat.random(in: 0...geo.size.width),
                    width: geo.size.width,
                    height: geo.size.height,
                    delay: Double.random(in: 0...1.2)
                )
            }
        }
    }
}

private struct ConfettiPiece: View {
    let color: Color
    let startX: CGFloat
    let width: CGFloat
    let height: CGFloat
    let delay: Double

    @State private var y: CGFloat = -30
    @State private var x: CGFloat = 0
    @State private var rotation: Double = 0
    @State private var opacity: Double = 1

    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(color)
            .frame(width: CGFloat.random(in: 8...16), height: CGFloat.random(in: 4...8))
            .rotationEffect(.degrees(rotation))
            .position(x: startX + x, y: y)
            .opacity(opacity)
            .onAppear {
                y = -30
                x = 0
                let duration = Double.random(in: 2.2...3.8)
                withAnimation(.easeIn(duration: duration).delay(delay)) {
                    y = height + 40
                    x = CGFloat.random(in: -60...60)
                    rotation = Double.random(in: 180...540)
                }
                withAnimation(.linear(duration: 0.4).delay(delay + duration - 0.4)) {
                    opacity = 0
                }
            }
    }
}

#Preview {
    CelebrationView(team: allNHLTeams[1])
        .environmentObject(AppState())
}
