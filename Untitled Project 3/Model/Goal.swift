import Foundation

/// The learning goal from onboarding.
/// `createdAt` is the start of the goal: logs before it are ignored,
/// so updating the goal (a new Goal) resets the streak and the Freezes.
struct Goal: Codable, Equatable {
    var subject: String
    var duration: LearningDuration
    var createdAt: Date = Date()
}


