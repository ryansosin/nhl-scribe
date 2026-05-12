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
}
