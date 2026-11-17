import SwiftUI

struct GoalFormView: View {
    @Binding var subject: String
    @Binding var duration: LearningDuration

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 36) {
            // I want to learn
            VStack(alignment: .leading, spacing: 12) {
                Text("I want to learn")
                    .font(.title3)
                    .foregroundColor(.white)

                TextField(
                    "",
                    text: $subject,
                    prompt: Text("Swift").foregroundColor(.gray.opacity(0.7))
                )
                .font(.title2)
                .foregroundColor(.white)
                .tint(.appOrange)
                .focused($isFocused)
                .submitLabel(.done)
                .autocorrectionDisabled()
                

                Rectangle()
                    .fill(isFocused ? Color.appOrange : Color.white.opacity(0.15))
                    .frame(height: 1)
                    .animation(.easeInOut(duration: 0.2), value: isFocused)
            }

            // I want to learn it in a  (week / month / year)
            VStack(alignment: .leading, spacing: 16) {
                Text("I want to learn it in a")
                    .font(.title3)
                    .foregroundColor(.white)

                DurationPicker(selection: $duration)
            }
        }
    }
}

#Preview {
    struct Wrapper: View {
        @State private var subject = ""
        @State private var duration: LearningDuration = .week
        var body: some View {
            GoalFormView(subject: $subject, duration: $duration)
                .padding()
                .background(Color.black)
        }
    }
    return Wrapper()
}
