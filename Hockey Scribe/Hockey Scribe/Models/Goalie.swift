import Foundation

struct Goalie: Identifiable, Codable {
    let id: Int
    let firstName: LocalizedName
    let lastName: LocalizedName
    let headshot: String
    let sweaterNumber: Int

    struct LocalizedName: Codable {
        let `default`: String
    }

    var fullName: String { "\(firstName.default) \(lastName.default)" }
    var headshotURL: URL? { URL(string: headshot) }
    var actionShotURL: URL? { URL(string: "https://assets.nhle.com/mugs/actionshots/1296x729/\(id).jpg") }
}

struct RosterResponse: Codable {
    let goalies: [Goalie]
    let forwards: [RosterPlayer]?
    let defensemen: [RosterPlayer]?
}

/// Minimal roster entry used to look up sweater numbers for skaters whose
/// stats come from a different endpoint (club-stats has points but no number).
struct RosterPlayer: Codable {
    let id: Int
    let sweaterNumber: Int
}
