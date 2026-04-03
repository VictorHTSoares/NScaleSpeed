import SwiftUI

struct HistoryList: View {
    let history: [SpeedResult]
    let onClear: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("RUN HISTORY")
                    .font(.system(size: 10, design: .monospaced))
                    .tracking(3)
                    .foregroundColor(Theme.textTertiary)
                Spacer()
                Button("CLEAR") { onClear() }
                    .font(.system(size: 10, design: .monospaced))
                    .tracking(1)
                    .foregroundColor(Theme.textTertiary)
            }

            VStack(spacing: 0) {
                ForEach(Array(history.enumerated()), id: \.element.id) { index, run in
                    let runNumber = history.count - index
                    let opacity = index == 0 ? 1.0 : 0.5 + 0.5 * (1.0 - Double(index) / Double(history.count))

                    HStack {
                        Text("#\(runNumber)")
                            .foregroundColor(Theme.textTertiary)
                            .frame(width: 30, alignment: .leading)

                        Text(formatTime(run.elapsed))
                            .foregroundColor(Theme.textSecondary)
                            .frame(width: 70, alignment: .leading)

                        Spacer()

                        Text(String(format: "%.1f km/h", run.realSpeed_kph))
                            .foregroundColor(Theme.gold)

                        Text(String(format: "%.1f mph", run.realSpeed_mph))
                            .foregroundColor(Theme.goldDim)
                            .frame(width: 75, alignment: .trailing)
                    }
                    .font(.system(size: 12, design: .monospaced))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .opacity(opacity)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Run \(runNumber): \(formatTime(run.elapsed)), \(String(format: "%.1f", run.realSpeed_kph)) km/h, \(String(format: "%.1f", run.realSpeed_mph)) mph")
                    .overlay(alignment: .bottom) {
                        if index < history.count - 1 {
                            Divider().background(Theme.borderSubtle)
                        }
                    }
                }
            }
            .background(Theme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Theme.border, lineWidth: 1)
            )
        }
    }
}
