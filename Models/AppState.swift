import Foundation
import Combine

class AppState: ObservableObject {

    // MARK: - Persisted
    @Published var childName: String {
        didSet { UserDefaults.standard.set(childName, forKey: "childName") }
    }

    /// Set of team IDs (abbreviations) the child has completed
    @Published var completedTeamIDs: Set<String> {
        didSet {
            let array = Array(completedTeamIDs)
            UserDefaults.standard.set(array, forKey: "completedTeamIDs")
        }
    }

    // MARK: - Session state
    @Published var currentTeam: NHLTeam?

    // MARK: - Init
    init() {
        self.childName = UserDefaults.standard.string(forKey: "childName") ?? ""
        let saved = UserDefaults.standard.stringArray(forKey: "completedTeamIDs") ?? []
        self.completedTeamIDs = Set(saved)
    }

    // MARK: - Team selection
    /// Picks the next random uncompleted team (reshuffles when all done).
    func pickNextTeam() {
        var pool = allNHLTeams.filter { !completedTeamIDs.contains($0.id) }
        if pool.isEmpty {
            // All done — reset and start over
            completedTeamIDs = []
            pool = allNHLTeams
        }
        currentTeam = pool.randomElement()
    }

    func markCurrentTeamCompleted() {
        guard let team = currentTeam else { return }
        completedTeamIDs.insert(team.id)
    }

    var isNameEntered: Bool { !childName.isEmpty }
}
