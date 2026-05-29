import SwiftUI
import AVFoundation

struct TeamView: View {
    @EnvironmentObject var appState: AppState
    let team: NHLTeam

    @State private var synthesizer = AVSpeechSynthesizer()
    @State private var logoVisible = false
    @State private var textVisible = false

    var body: some View {
        ZStack {
            team.primarySwiftUIColor.ignoresSafeArea()

            VStack(spacing: 16) {
                Group {
                    if UIImage(named: team.logoAssetName) != nil {
                        Image(team.logoAssetName)
                            .resizable()
                            .scaledToFit()
                    } else {
                        Image(systemName: "hockey.puck.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(team.secondarySwiftUIColor.opacity(0.6))
                    }
                }
                .frame(width: 560, height: 560)
                .padding(.top, 36)
                .scaleEffect(logoVisible ? 1.0 : 0.4)
                .opacity(logoVisible ? 1.0 : 0)
                .animation(.spring(response: 0.55, dampingFraction: 0.65), value: logoVisible)

                VStack(spacing: 4) {
                    Text(team.nickname)
                        .font(.system(size: 64, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 4, y: 2)

                    Text(team.fullName)
                        .font(.system(size: 26, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.75))
                }
                .opacity(textVisible ? 1.0 : 0)
                .offset(y: textVisible ? 0 : 20)
                .animation(.easeOut(duration: 0.4).delay(0.2), value: textVisible)
            }
            .padding(.horizontal, 40)
        }
        .safeAreaInset(edge: .bottom) {
            Button(action: {
                appState.sessionPhase = .tracing
            }) {
                Text("Let's Go!")
                    .font(.system(size: 36, weight: .black, design: .rounded))
                    .foregroundColor(team.primarySwiftUIColor)
                    .frame(width: 280, height: 90)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .shadow(color: .black.opacity(0.25), radius: 12, y: 6)
            }
            .opacity(textVisible ? 1.0 : 0)
            .animation(.easeOut(duration: 0.4).delay(0.45), value: textVisible)
            .padding(.bottom, 32)
        }
        .onAppear {
            logoVisible = true
            textVisible = true
            speakIntro()
        }
        .onDisappear {
            synthesizer.stopSpeaking(at: .immediate)
        }
    }

    private func speakIntro() {
        let text = "Let's write \(team.nickname), \(appState.childName)!"
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = 0.42
        utterance.pitchMultiplier = 1.1
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            synthesizer.speak(utterance)
        }
    }
}

#Preview {
    TeamView(team: allNHLTeams[0])
        .environmentObject(AppState())
}
