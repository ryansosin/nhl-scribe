import Foundation

struct Skater: Identifiable, Codable {
    let playerId: Int
    let firstName: LocalizedName
    let lastName: LocalizedName
    let headshot: String
    let positionCode: String
    let goals: Int
    let assists: Int
    let points: Int

    struct LocalizedName: Codable {
        let `default`: String
    }

    var id: Int { playerId }
    var fullName: String { "\(firstName.default) \(lastName.default)" }
    var headshotURL: URL? { URL(string: headshot) }
    var actionShotURL: URL? { URL(string: "https://assets.nhle.com/mugs/actionshots/1296x729/\(playerId).jpg") }
}

struct ClubStatsResponse: Codable {
    let skaters: [Skater]
}
