import Foundation

struct DayLog: Codable, Identifiable, Equatable {
    var id = UUID()
    let status: DayStatus
    let loggedAt: Date

    init(status: DayStatus, loggedAt: Date = Date()) {
        self.status = status
        self.loggedAt = loggedAt
    }
}
enum DayStatus: String, Codable {
    case learned
    case freezed
}

