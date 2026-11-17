import SwiftUI

extension Color {
    static let freezeBlue = Color(red: 0.42, green: 0.80, blue: 0.96)
}

/// Glass Freeze button + "x out of N Freezes used" caption.
/// - Available: "Freeze for a day" (blue glass)
/// - Freeze active (pressed in the last 24h): looks like the disabled design
///   ("Freezed for a day", black glass) but is tappable: `onUndo` asks the user
///   if they want to undo the Freeze.
/// - All Freezes used / learned today: black glass, disabled
struct FreezeButton: View {
    let isFreezeActive: Bool
    let isLoggedToday: Bool
    let usedFreezes: Int
    let totalFreezes: Int
    let onFreeze: () -> Void
    let onUndo: () -> Void

    private var noFreezesLeft: Bool { usedFreezes >= totalFreezes }

    /// Really disabled (no tap).
    private var isDisabled: Bool {
        if isFreezeActive { return false }
        return isLoggedToday || noFreezesLeft
    }

    /// Drawn as "off" (black glass, gray text), even when tappable for undo.
    private var looksOff: Bool { isFreezeActive || isDisabled }

    private var title: String {
        (isFreezeActive || noFreezesLeft) ? "Freezed for a day" : "Freeze for a day"
    }

    var body: some View {
        VStack(spacing: 14) {
            Button(action: isFreezeActive ? onUndo : onFreeze) {
                Text(title)
                    .font(.title3.weight(.medium))
                    .foregroundColor(looksOff ? .gray : .white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .glassBackground(in: Capsule(), tint: looksOff ? .glassBlack : .freezeBlue)
            }
            .buttonStyle(PressScaleButtonStyle())
            .disabled(isDisabled)
            .animation(.easeInOut(duration: 0.25), value: looksOff)

            Text("\(usedFreezes) out of \(totalFreezes) Freezes used")
                .font(.footnote)
                .foregroundColor(.gray)
        }
    }
}

#Preview {
    VStack(spacing: 30) {
        FreezeButton(isFreezeActive: false, isLoggedToday: false, usedFreezes: 0, totalFreezes: 2, onFreeze: {}, onUndo: {})
        FreezeButton(isFreezeActive: true, isLoggedToday: false, usedFreezes: 1, totalFreezes: 2, onFreeze: {}, onUndo: {})
        FreezeButton(isFreezeActive: false, isLoggedToday: true, usedFreezes: 0, totalFreezes: 2, onFreeze: {}, onUndo: {})
        FreezeButton(isFreezeActive: false, isLoggedToday: false, usedFreezes: 2, totalFreezes: 2, onFreeze: {}, onUndo: {})
    }
    .padding()
    .background(Color.gray.opacity(0.3))
}


struct ConfirmPopup: View {
    let title: String
    let message: String
    var cancelTitle: String = "Dismiss"
    let confirmTitle: String
    var confirmTint: Color = .appOrange
    let onCancel: () -> Void
    let onConfirm: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.55)
                .ignoresSafeArea()
                .onTapGesture(perform: onCancel)

            VStack(alignment: .leading, spacing: 10) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)

                Text(message)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))

                HStack(spacing: 12) {
                    Button(action: onCancel) {
                        Text(cancelTitle)
                            .font(.title3.weight(.medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .glassBackground(in: Capsule(), tint: .glassBlack)
                    }
                    .buttonStyle(PressScaleButtonStyle())

                    Button(action: onConfirm) {
                        Text(confirmTitle)
                            .font(.title3.weight(.medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .glassBackground(in: Capsule(), tint: confirmTint)
                    }
                    .buttonStyle(PressScaleButtonStyle())
                }
                .padding(.top, 10)
            }
            .padding(20)
            .frame(maxWidth: 340)
            .background(
                RoundedRectangle(cornerRadius: 34, style: .continuous)
                    .fill(Color(white: 0.10))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 34, style: .continuous)
                    .stroke(Color.white.opacity(0.10), lineWidth: 1)
            )
            .padding(.horizontal, 24)
        }
        .transition(.opacity)
    }
}

#Preview {
    ConfirmPopup(
        title: "Undo Freeze",
        message: "Do you want to undo today's Freeze? You'll get it back.",
        confirmTitle: "Undo",
        confirmTint: .freezeBlue,
        onCancel: {},
        onConfirm: {}
    )
}
