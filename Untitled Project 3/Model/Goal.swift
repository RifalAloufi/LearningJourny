import Foundation

struct Goal: Codable, Equatable {
    var subject: String
    var duration: LearningDuration
    var createdAt: Date = Date()
}


