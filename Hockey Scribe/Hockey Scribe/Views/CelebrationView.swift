import SwiftUI
import AVFoundation

struct CelebrationView: View {
    @EnvironmentObject var appState: AppState
    let team: NHLTeam

    @State private var goalScale: CGFloat = 0.1
    @State private var goalOpacity: Double = 0
    @State private var showConfetti = false
    @State private var synthesizer = AVSpeechSynthesizer()

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if showConfetti {
                ConfettiLayer(primary: team.primarySwiftUIColor, secondary: team.secondarySwiftUIColor)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }

            VStack(spacing: 16) {
                Text("GOAL!")
                    .font(.system(size: 120, weight: .black, design: .rounded))
                    .foregroundColor(.yellow)
                    .shadow(color: .yellow.opacity(0.6), radius: 24, y: 0)
                    .scaleEffect(goalScale)
                    .opacity(goalOpacity)

                if let snapshot = appState.tracingSnapshot {
                    Image(uiImage: snapshot)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 2400, maxHeight: 1080)
                        .opacity(goalOpacity)
                }

                Text("Amazing job, \(appState.childName)!")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .opacity(goalOpacity)
            }

            VStack {
                Spacer()
                Button("Keep going!") { advance() }
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.black)
                    .frame(width: 260, height: 72)
                    .background(Color.yellow)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .opacity(goalOpacity)
                    .padding(.bottom, 48)
            }
        }
        .onAppear {
            showConfetti = true
            withAnimation(.spring(response: 0.45, dampingFraction: 0.5)) {
                goalScale = 1.0
                goalOpacity = 1.0
            }
            speakCelebration()
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) { advance() }
        }
        .onDisappear {
            synthesizer.stopSpeaking(at: .immediate)
        }
    }

    private func advance() {
        switch appState.sessionPhase {
        case .celebration:
            appState.sessionPhase = .goalie
        default:
            appState.sessionPhase = .goalHorn
        }
    }

    private func speakCelebration() {
        let utterance = AVSpeechUtterance(string: "Amazing job, \(appState.childName)!")
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
