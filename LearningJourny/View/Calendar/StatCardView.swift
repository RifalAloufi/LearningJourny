import SwiftUI

/// "1 day" / "4 days" — singular when the number is exactly 1.
func dayCountText(_ count: Int) -> String {
    "\(count) \(count == 1 ? "day" : "days")"
}

/// Black glass card (Learned / Freezed counters).
struct StatCardView: View {
    let systemImage: String
    let tint: Color
    let value: Int
    let title: String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: systemImage)
                .font(.title3)
                .foregroundColor(tint)

            Text(dayCountText(value))
                .font(.headline)
                .foregroundColor(.white)

            Text(title)
                .font(.footnote)
                .foregroundColor(.white.opacity(0.85))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 22)
        .glassBackground(
            in: RoundedRectangle(cornerRadius: 34, style: .continuous),
            tint: Color.black.opacity(0.6)
        )
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    HStack(spacing: 14) {
        StatCardView(systemImage: "flame.fill", tint: .appOrange, value: 1, title: "Learned")
        StatCardView(systemImage: "snowflake", tint: .freezeBlue, value: 0, title: "Freezed")
    }
    .padding()
    .background(Color.gray.opacity(0.3))
}
