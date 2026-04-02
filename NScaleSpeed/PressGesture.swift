import SwiftUI

struct PressGestureModifier: ViewModifier {
    let onDown: () -> Void
    let onUp: () -> Void

    @State private var hasFired = false

    func body(content: Content) -> some View {
        content
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !hasFired {
                            hasFired = true
                            onDown()
                        }
                    }
                    .onEnded { value in
                        let dx = value.translation.width
                        let dy = value.translation.height
                        let distance = sqrt(dx * dx + dy * dy)
                        hasFired = false
                        if distance < 20 {
                            onUp()
                        }
                        // else: large drag — treat as accidental/system cancellation, ignore
                    }
            )
    }
}

extension View {
    func onPressGesture(onDown: @escaping () -> Void, onUp: @escaping () -> Void) -> some View {
        modifier(PressGestureModifier(onDown: onDown, onUp: onUp))
    }
}
