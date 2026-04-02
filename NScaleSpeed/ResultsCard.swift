import SwiftUI

struct ResultsCard: View {
    let result: SpeedResult

    var body: some View {
        VStack(spacing: 0) {
            // Header
            Text("REAL-WORLD EQUIVALENT SPEED")
                .font(.system(size: 10, design: .monospaced))
                .tracking(3)
                .foregroundColor(Theme.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .overlay(alignment: .bottom) { Divider().background(Theme.border) }

            // Primary result
            VStack(spacing: 4) {
                Text(String(format: "%.1f", result.realSpeed_kph))
                    .font(.system(size: 42, weight: .light, design: .monospaced))
                    .foregroundColor(Theme.gold)

                Text("km/h")
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundColor(Theme.textSecondary)

                Text(String(format: "%.1f mph", result.realSpeed_mph))
                    .font(.system(size: 22, weight: .light, design: .monospaced))
                    .foregroundColor(Theme.goldDim)
                    .padding(.top, 4)
            }
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity)
            .overlay(alignment: .bottom) { Divider().background(Theme.border) }

            // Detail rows
            DetailRow(label: "Model speed", value: String(format: "%.4f m/s", result.modelSpeed_mps))
            DetailRow(label: "Model speed", value: String(format: "%.2f km/h", result.scaleSpeed_kph))
            DetailRow(label: "Real speed", value: String(format: "%.2f m/s", result.realSpeed_mps))
            DetailRow(label: "Track (model)", value: String(format: "%.0f mm", result.trackMM))
            DetailRow(label: "Track (real)", value: String(format: "%.1f m", result.trackRealM))
            DetailRow(label: "Scale ratio", value: "1:160", isLast: true)
        }
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Theme.border, lineWidth: 1)
        )
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    var isLast: Bool = false

    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(Theme.textSecondary)
            Spacer()
            Text(value)
                .foregroundColor(Theme.textPrimary.opacity(0.7))
        }
        .font(.system(size: 12, design: .monospaced))
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .overlay(alignment: .bottom) {
            if !isLast {
                Divider().background(Theme.borderSubtle)
            }
        }
    }
}
