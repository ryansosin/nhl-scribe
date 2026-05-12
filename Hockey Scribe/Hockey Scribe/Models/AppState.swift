import Foundation
import Combine

enum SessionPhase {
    case home, teamIntro, tracing, celebration, goalie, goalieTracing, goalCelebration, goalHorn
}

class AppState: ObservableObject {

    // MARK: - Persisted
    @Published var childName: String {
        didSet { UserDefaults.standard.set(childName, forKey: "childName") }
    }

    @Published var completedTeamIDs: Set<String> {
        didSet {
            let array = Array(completedTeamIDs)
            UserDefaults.standard.set(array, forKey: "completedTeamIDs")
        }
    }

    // MARK: - Session state
    @Published var currentTeam: NHLTeam?
    @Published var currentGoalie: Goalie?
    @Published var sessionPhase: SessionPhase = .home

    // MARK: - Init
    init() {
        self.childName = UserDefaults.standard.string(forKey: "childName") ?? ""
        let saved = UserDefaults.standard.stringArray(forKey: "completedTeamIDs") ?? []
        self.completedTeamIDs = Set(saved)
    }

    // MARK: - Team selection
    func pickNextTeam() {
        var pool = allNHLTeams.filter { !completedTeamIDs.contains($0.id) }
        if pool.isEmpty {
            completedTeamIDs = []
            pool = allNHLTeams
        }
        currentTeam = pool.randomElement()
        sessionPhase = .teamIntro
    }

    func markCurrentTeamCompleted() {
        guard let team = currentTeam else { return }
        completedTeamIDs.insert(team.id)
    }

    var isNameEntered: Bool { !childName.isEmpty }
}
