import SwiftUI

/// Root router — swaps between name entry, home, and session screens.
struct ContentView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        Group {
            if !appState.isNameEntered {
                NameEntryView()
            } else {
                switch appState.sessionPhase {
                case .home:
                    HomeView()
                case .teamIntro:
                    if let team = appState.currentTeam {
                        TeamView(team: team)
                    }
                case .tracing:
                    if let team = appState.currentTeam {
                        TracingView(team: team, word: team.nickname)
                    }
                case .celebration, .goalCelebration:
                    if let team = appState.currentTeam {
                        CelebrationView(team: team)
                    }
                case .goalie:
                    if let team = appState.currentTeam {
                        GoalieView(team: team)
                    }
                case .goalHorn:
                    if let team = appState.currentTeam {
                        GoalHornView(team: team)
                    }
                case .stickerAward:
                    if let team = appState.currentTeam {
                        StickerAwardView(team: team)
                    }
                case .goalieTracing:
                    if let team = appState.currentTeam,
                       let goalie = appState.currentGoalie {
                        TracingView(team: team, word: goalie.lastName.default.uppercased(), headerImageURL: goalie.actionShotURL)
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
}
