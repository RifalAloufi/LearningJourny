import SwiftUI

// NOTE: `LearningDuration` is defined in Models/GoalPage/LearningDuration.swift.
// Do not declare it again in this file.

/// Week / Month / Year chips with the glass effect:
/// selected = orange glass, others = black glass.
struct DurationPicker: View {
    @Binding var selection: LearningDuration

    var body: some View {
        HStack(spacing: 14) {
            ForEach(LearningDuration.allCases) { duration in
                chip(for: duration)
            }
        }
    }

    private func chip(for duration: LearningDuration) -> some View {
        let isSelected = duration == selection

        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                selection = duration
            }
        } label: {
            Text(duration.rawValue)
                .font(.title3.weight(.medium))
                .foregroundColor(isSelected ? .white : .gray)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .glassBackground(in: Capsule(), tint: isSelected ? .appOrange : .glassBlack)
        }
        .buttonStyle(PressScaleButtonStyle())
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    struct Wrapper: View {
        @State private var duration: LearningDuration = .week
        var body: some View {
            DurationPicker(selection: $duration)
                .padding()
                .background(Color.gray.opacity(0.3))
        }
    }
    return Wrapper()
}
