import SwiftUI
import AVFoundation

struct ScorersView: View {
    @EnvironmentObject var appState: AppState
    let team: NHLTeam

    @State private var skaters: [Skater] = []
    @State private var sweaterNumbers: [Int: Int] = [:]
    @State private var isLoading = true
    @State private var selectedID: Int?
    @State private var synthesizer = AVSpeechSynthesizer()

    var body: some View {
        ZStack {
            team.primarySwiftUIColor.ignoresSafeArea()

            VStack(spacing: 32) {
                Text("Tap a scorer, \(appState.childName)!")
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
                } else if skaters.isEmpty {
                    Spacer()
                    Text("No scorers found")
                        .foregroundColor(.white.opacity(0.6))
                        .font(.system(size: 24, design: .rounded))
                    Spacer()
                } else {
                    Spacer()
                    HStack(spacing: 24) {
                        ForEach(skaters) { skater in
                            ScorerCard(
                                skater: skater,
                                sweaterNumber: sweaterNumbers[skater.id],
                                isSelected: selectedID == skater.id,
                                teamColor: team.primarySwiftUIColor
                            )
                            .onTapGesture { tapped(skater) }
                        }
                    }
                    .padding(.horizontal, 32)
                    Spacer()
                }
            }
        }
        .task { await loadSkaters() }
        .onAppear { speakPrompt() }
        .onDisappear { synthesizer.stopSpeaking(at: .immediate) }
    }

    private func tapped(_ skater: Skater) {
        guard selectedID == nil else { return }
        selectedID = skater.id
        appState.currentSkater = skater
        speakName(skater.fullName)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            appState.sessionPhase = .scorerTracing
        }
    }

    private func loadSkaters() async {
        async let stats = fetchStats()
        async let roster = fetchRoster()
        let (statsResult, rosterResult) = await (stats, roster)

        let top = Array((statsResult?.skaters ?? [])
            .sorted { $0.points > $1.points }
            .prefix(3))
        var lookup: [Int: Int] = [:]
        let rosterPlayers = (rosterResult?.forwards ?? []) + (rosterResult?.defensemen ?? [])
        for player in rosterPlayers {
            lookup[player.id] = player.sweaterNumber
        }

        await MainActor.run {
            skaters = top
            sweaterNumbers = lookup
            isLoading = false
        }
    }

    private func fetchStats() async -> ClubStatsResponse? {
        let url = URL(string: "https://api-web.nhle.com/v1/club-stats/\(team.id)/now")!
        guard let (data, _) = try? await URLSession.shared.data(from: url) else { return nil }
        return try? JSONDecoder().decode(ClubStatsResponse.self, from: data)
    }

    private func fetchRoster() async -> RosterResponse? {
        let url = URL(string: "https://api-web.nhle.com/v1/roster/\(team.id)/current")!
        guard let (data, _) = try? await URLSession.shared.data(from: url) else { return nil }
        return try? JSONDecoder().decode(RosterResponse.self, from: data)
    }

    private func speakPrompt() {
        let utterance = AVSpeechUtterance(string: "Tap a scorer, \(appState.childName)!")
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

private struct ScorerCard: View {
    let skater: Skater
    let sweaterNumber: Int?
    let isSelected: Bool
    let teamColor: Color

    var body: some View {
        VStack(spacing: 0) {
            AsyncImage(url: skater.headshotURL) { phase in
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
            .frame(width: 400, height: 440)
            .clipped()

            VStack(spacing: 2) {
                Text(sweaterNumber.map { "#\($0)" } ?? "")
                    .font(.system(size: 48, weight: .black, design: .rounded))
                    .foregroundColor(isSelected ? teamColor : .black)
                Text(skater.lastName.default)
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
