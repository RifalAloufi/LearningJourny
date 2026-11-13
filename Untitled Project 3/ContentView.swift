import SwiftUI

struct ContentView: View {
    @State private var goal: Goal? = ActivityViewModel.storedGoal()

    var body: some View {
        let _ = print("RootView goal:", goal as Any)

        Group {
            if let goal {
                ActivityScreen(goal: goal, onEditGoal: { self.goal = nil })
                    .id(goal.createdAt)
            } else {
                OnboardingView { subject, duration in
                    goal = Goal(subject: subject, duration: duration)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}
