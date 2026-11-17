
import SwiftUI

extension Color {
    static let appOrange = Color(red: 0.91, green: 0.58, blue: 0.25)
    static let chipBackground = Color.white.opacity(0.08)
    
}
    extension Color {
        static let glassBlack = Color.black.opacity(0.55)
    }

    extension View {

        @ViewBuilder
        func glassBackground<S: Shape>(in shape: S, tint: Color? = nil) -> some View {
            if #available(iOS 26.0, *) {
                if let tint {
                    self.glassEffect(.regular.tint(tint), in: shape)
                } else {
                    self.glassEffect(.regular, in: shape)
                }
            } else {
                self
                    .background(
                        shape.fill(tint?.opacity(0.9) ?? Color.white.opacity(0.08))
                    )
                    .background(shape.fill(.ultraThinMaterial))
                    .overlay(shape.stroke(Color.white.opacity(0.15), lineWidth: 1))
            }
        }
    }


