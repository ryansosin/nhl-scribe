import Foundation
import Combine
import UIKit

enum SessionPhase {
    case home, teamIntro, tracing, celebration, goalie, goalieTracing, goalCelebration, scorers, scorerTracing, scorerCelebration, goalHorn, stickerAward
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
    @Published var currentSkater: Skater?
    @Published var sessionPhase: SessionPhase = .home
    @Published var tracingSnapshot: UIImage?
    @Published var openStickerBookOnHome = false

    // MARK: - Init
    init() {
        self.childName = UserDefaults.standard.string(forKey: "childName") ?? ""
        let saved = UserDefaults.standard.stringArray(forKey: "completedTeamIDs") ?? []
        self.completedTeamIDs = Set(saved)
    }

    // MARK: - Team selection
    func pickNextTeam() {
        let nonDET = allNHLTeams.filter { $0.id != "DET" }
        let det = allNHLTeams.first { $0.id == "DET" }

        // All 31 non-DET teams done — play Red Wings as the finale
        let nonDETRemaining = nonDET.filter { !completedTeamIDs.contains($0.id) }
        if nonDETRemaining.isEmpty && !completedTeamIDs.contains("DET") {
            currentTeam = det
            sessionPhase = .teamIntro
            return
        }

        // Full cycle complete — reset and start fresh (DET still goes last)
        if nonDETRemaining.isEmpty {
            completedTeamIDs = []
            currentTeam = nonDET.randomElement()
            sessionPhase = .teamIntro
            return
        }

        currentTeam = nonDETRemaining.randomElement()
        sessionPhase = .teamIntro
    }

    func markCurrentTeamCompleted() {
        guard let team = currentTeam else { return }
        completedTeamIDs.insert(team.id)
    }

    var isNameEntered: Bool { !childName.isEmpty }
}
