import SwiftUI
import AVFoundation

struct GoalieView: View {
    @EnvironmentObject var appState: AppState
    let team: NHLTeam

    @State private var goalies: [Goalie] = []
    @State private var isLoading = true
    @State private var selectedID: Int?
    @State private var synthesizer = AVSpeechSynthesizer()

    var body: some View {
        ZStack {
            team.primarySwiftUIColor.ignoresSafeArea()

            VStack(spacing: 32) {
                Text("Tap a goalie, \(appState.childName)!")
                    .font(.system(size: 36, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
                    .padding(.top, 48)

                if isLoading {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.white)
                        .scaleEffect(2)
                    Spacer()
                } else if goalies.isEmpty {
                    Spacer()
                    Text("No goalies found")
                        .foregroundColor(.white.opacity(0.6))
                        .font(.system(size: 24, design: .rounded))
                    Spacer()
                } else {
                    Spacer()
                    HStack(spacing: 24) {
                        ForEach(goalies) { goalie in
                            GoalieCard(
                                goalie: goalie,
                                isSelected: selectedID == goalie.id,
                                teamColor: team.primarySwiftUIColor
                            )
                            .onTapGesture { tapped(goalie) }
                        }
                    }
                    .padding(.horizontal, 32)
                    Spacer()
                }
            }
        }
        .task { await loadGoalies() }
        .onAppear { speakPrompt() }
        .onDisappear { synthesizer.stopSpeaking(at: .immediate) }
    }

    private func tapped(_ goalie: Goalie) {
        guard selectedID == nil else { return }
        selectedID = goalie.id
        appState.currentGoalie = goalie
        speakName(goalie.fullName)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            appState.sessionPhase = .goalieTracing
        }
    }

    private func loadGoalies() async {
        let url = URL(string: "https://api-web.nhle.com/v1/roster/\(team.id)/current")!
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let roster = try JSONDecoder().decode(RosterResponse.self, from: data)
            await MainActor.run {
                goalies = Array(roster.goalies.prefix(3))
                isLoading = false
            }
        } catch {
            await MainActor.run { isLoading = false }
        }
    }

    private func speakPrompt() {
        let utterance = AVSpeechUtterance(string: "Tap a goalie, \(appState.childName)!")
        utterance.rate = 0.42
        utterance.pitchMultiplier = 1.1
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            synthesizer.speak(utterance)
        }
    }

    private func speakName(_ name: String) {
        synthesizer.stopSpeaking(at: .immediate)
        let utterance = AVSpeechUtterance(string: name)
        utterance.rate = 0.40
        utterance.pitchMultiplier = 1.05
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        synthesizer.speak(utterance)
    }
}

private struct GoalieCard: View {
    let goalie: Goalie
    let isSelected: Bool
    let teamColor: Color

    var body: some View {
        VStack(spacing: 0) {
            AsyncImage(url: goalie.headshotURL) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                case .failure, .empty:
                    Color.white.opacity(0.15)
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.white.opacity(0.4))
                        )
                @unknown default:
                    Color.white.opacity(0.15)
                }
            }
            .frame(width: 200, height: 220)
            .clipped()

            VStack(spacing: 2) {
                Text("#\(goalie.sweaterNumber)")
                    .font(.system(size: 48, weight: .black, design: .rounded))
                    .foregroundColor(isSelected ? teamColor : .black)
                Text(goalie.lastName.default)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(isSelected ? teamColor : .black.opacity(0.7))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? Color.yellow : Color.white)
        }
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: isSelected ? .yellow.opacity(0.6) : .black.opacity(0.3),
                radius: isSelected ? 20 : 8, y: 4)
        .scaleEffect(isSelected ? 1.06 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
    }
}
