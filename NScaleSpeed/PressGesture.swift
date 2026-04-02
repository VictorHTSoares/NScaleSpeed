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
                    .onEnded { _ in
                        hasFired = false
                        onUp()
                    }
            )
    }
}

extension View {
    func onPressGesture(onDown: @escaping () -> Void, onUp: @escaping () -> Void) -> some View {
        modifier(PressGestureModifier(onDown: onDown, onUp: onUp))
    }
}
