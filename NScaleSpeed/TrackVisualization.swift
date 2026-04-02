import SwiftUI

struct TrackVisualization: View {
    let phase: TimerPhase
    let modeColor: Color

    var body: some View {
        VStack(spacing: 0) {
            // Labels row
            HStack {
                Text("START")
                    .font(.system(size: 9, design: .monospaced))
                    .foregroundColor(Theme.textSecondary)
                Spacer()
                Text("STOP")
                    .font(.system(size: 9, design: .monospaced))
                    .foregroundColor(Theme.textSecondary)
            }
            .padding(.bottom, 6)

            // Track
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height

                ZStack {
                    // Rails
                    Rectangle()
                        .fill(Theme.textTertiary)
                        .frame(height: 2)
                        .offset(y: -8)
                    Rectangle()
                        .fill(Theme.textTertiary)
                        .frame(height: 2)
                        .offset(y: 8)

                    // Ties
                    ForEach(0..<18, id: \.self) { i in
                        Rectangle()
                            .fill(Color(red: 0.16, green: 0.16, blue: 0.13))
                            .frame(width: 3, height: 24)
                            .offset(x: -w / 2 + (CGFloat(i) + 0.5) * (w / 18))
                    }

                    // Start marker
                    Rectangle()
                        .fill(phase == .running ? modeColor : (phase == .armed ? Theme.purple : Theme.gold))
                        .frame(width: 2, height: h)
                        .shadow(color: phase == .running ? modeColor.opacity(0.4) : .clear, radius: 4)
                        .offset(x: -w / 2 + 1)

                    // End marker
                    Rectangle()
                        .fill(phase == .result ? Theme.red : Theme.gold)
                        .frame(width: 2, height: h)
                        .shadow(color: phase == .result ? Theme.red.opacity(0.4) : .clear, radius: 4)
                        .offset(x: w / 2 - 1)

                    // Train indicator
                    if phase == .running {
                        TrainDot(color: modeColor, trackWidth: w)
                    }
                }
            }
            .frame(height: 40)
        }
    }
}

struct TrainDot: View {
    let color: Color
    let trackWidth: CGFloat
    @State private var atEnd = false

    var body: some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(color)
            .frame(width: 14, height: 14)
            .shadow(color: color.opacity(0.5), radius: 6)
            .offset(x: atEnd ? (trackWidth / 2 - 20) : (-trackWidth / 2 + 8))
            .onAppear {
                withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                    atEnd = true
                }
            }
    }
}
