import SwiftUI

struct ContentView: View {
    @StateObject private var vm = SpeedViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // MARK: Header
                VStack(spacing: 4) {
                    Text("Scale Speedometer")
                        .font(.system(size: 28, weight: .regular, design: .serif))
                        .foregroundColor(Theme.gold)

                    Text("1:\(Int(vm.selectedScale.ratio)) · \(vm.selectedScale.brand.uppercased())")
                        .font(.system(size: 11, design: .monospaced))
                        .tracking(3)
                        .foregroundColor(Theme.textSecondary)
                }
                .padding(.top, 16)
                .padding(.bottom, 24)

                // MARK: Scale Selector
                HStack(spacing: 8) {
                    ForEach(scaleOptions) { scale in
                        Button {
                            if vm.canChangeSettings && vm.selectedScale.id != scale.id {
                                vm.selectedScale = scale
                                vm.selectedTrack = scale.tracks[0]
                                vm.reset()
                            }
                        } label: {
                            VStack(spacing: 2) {
                                Text(scale.label)
                                    .font(.system(size: 13, weight: vm.selectedScale.id == scale.id ? .medium : .regular, design: .monospaced))
                                Text("1:\(Int(scale.ratio))")
                                    .font(.system(size: 9, design: .monospaced))
                                    .tracking(1)
                                    .foregroundColor(vm.selectedScale.id == scale.id ? Theme.textSecondary : Theme.textTertiary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(vm.selectedScale.id == scale.id ? Theme.border : .clear)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(vm.selectedScale.id == scale.id ? Theme.gold.opacity(0.2) : Theme.border, lineWidth: 1)
                            )
                        }
                        .foregroundColor(vm.selectedScale.id == scale.id ? Theme.gold : Theme.textTertiary)
                        .opacity(!vm.canChangeSettings && vm.selectedScale.id != scale.id ? 0.3 : 1)
                        .disabled(!vm.canChangeSettings)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 12)

                // MARK: Track Selector
                HStack(spacing: 8) {
                    ForEach(vm.selectedScale.tracks) { track in
                        Button {
                            if vm.canChangeSettings { vm.selectedTrack = track }
                        } label: {
                            VStack(spacing: 2) {
                                Text(track.label)
                                    .font(.system(size: 13, weight: vm.selectedTrack.id == track.id ? .medium : .regular, design: .monospaced))
                                Text(track.sublabel)
                                    .font(.system(size: 9, design: .monospaced))
                                    .tracking(1)
                                    .foregroundColor(vm.selectedTrack.id == track.id ? Theme.textSecondary : Theme.textTertiary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(vm.selectedTrack.id == track.id ? Theme.border : .clear)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(vm.selectedTrack.id == track.id ? Theme.gold.opacity(0.2) : Theme.border, lineWidth: 1)
                            )
                        }
                        .foregroundColor(vm.selectedTrack.id == track.id ? Theme.gold : Theme.textTertiary)
                        .opacity(!vm.canChangeSettings && vm.selectedTrack.id != track.id ? 0.3 : 1)
                        .disabled(!vm.canChangeSettings)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 12)

                // MARK: Mode Selector
                HStack(spacing: 6) {
                    ForEach(TriggerMode.allCases) { mode in
                        let isSelected = vm.triggerMode == mode
                        let color = Theme.modeColor(mode)

                        Button {
                            if vm.canChangeSettings {
                                vm.triggerMode = mode
                                vm.reset()
                            }
                        } label: {
                            VStack(spacing: 2) {
                                Text(mode.icon)
                                    .font(.system(size: 14))
                                Text(mode.label.uppercased())
                                    .font(.system(size: 9, weight: isSelected ? .medium : .regular, design: .monospaced))
                                    .tracking(1)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(isSelected ? Theme.border : .clear)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(isSelected ? color.opacity(0.2) : Theme.border, lineWidth: 1)
                            )
                        }
                        .foregroundColor(isSelected ? color : Theme.textTertiary)
                        .opacity(!vm.canChangeSettings && !isSelected ? 0.3 : 1)
                        .disabled(!vm.canChangeSettings)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)

                // MARK: Track Visual
                TrackVisualization(phase: vm.phase, modeColor: Theme.modeColor(vm.triggerMode))
                    .padding(.horizontal, 20)
                    .padding(.bottom, 28)

                // MARK: Timer Display
                VStack(spacing: 4) {
                    if vm.phase == .armed {
                        Text("ARMED")
                            .font(.system(size: 48, weight: .light, design: .monospaced))
                            .tracking(2)
                            .foregroundColor(Theme.purple)
                    } else {
                        Text(formatTime(vm.elapsed))
                            .font(.system(size: 48, weight: .light, design: .monospaced))
                            .tracking(2)
                            .foregroundColor(timerColor)
                            .opacity(vm.phase == .running ? timerPulse : 1)
                            .animation(
                                vm.phase == .running
                                    ? .easeInOut(duration: 0.5).repeatForever(autoreverses: true)
                                    : .default,
                                value: vm.phase == .running
                            )
                            .onChange(of: vm.phase) { _, newPhase in
                                timerPulse = newPhase == .running ? 0.4 : 1.0
                            }
                    }

                    Text(vm.phase == .armed ? "RELEASE TO START" : "ELAPSED TIME")
                        .font(.system(size: 10, design: .monospaced))
                        .tracking(2)
                        .foregroundColor(Theme.textTertiary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .overlay(alignment: .top) { Divider().background(Theme.border) }
                .overlay(alignment: .bottom) { Divider().background(Theme.border) }
                .padding(.horizontal, 20)
                .padding(.bottom, 28)

                // MARK: Action Button
                HStack(spacing: 12) {
                    TimerButton(vm: vm)

                    if vm.phase == .result {
                        Button { vm.reset() } label: {
                            Text("RESET")
                                .font(.system(size: 14, weight: .regular, design: .monospaced))
                                .tracking(2)
                                .foregroundColor(Theme.textSecondary)
                                .padding(.vertical, 18)
                                .padding(.horizontal, 20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Theme.border, lineWidth: 1)
                                )
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 8)

                // Mode hint
                Text(vm.triggerMode.desc)
                    .font(.system(size: 11, design: .monospaced))
                    .tracking(1)
                    .foregroundColor(Theme.textTertiary)
                    .padding(.bottom, 24)

                // MARK: Results
                if let result = vm.result {
                    ResultsCard(result: result)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 24)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                }

                // MARK: History
                if !vm.history.isEmpty {
                    HistoryList(history: vm.history, onClear: { vm.clearHistory() })
                        .padding(.horizontal, 20)
                        .padding(.bottom, 24)
                }

                // MARK: Footer
                Text("Place your loco at one end of a Bachmann E-Z Track straight section. Time the train as it crosses from one end to the other.")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(Theme.textTertiary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 40)
            }
        }
        .background(Theme.bg)
        .animation(.easeInOut(duration: 0.2), value: vm.phase)
    }

    // MARK: - Helpers

    private var timerColor: Color {
        switch vm.phase {
        case .idle: return Theme.textTertiary
        case .armed: return Theme.purple
        case .running: return Theme.modeColor(vm.triggerMode)
        case .result: return Theme.gold
        }
    }

    @State private var timerPulse: Double = 1.0
}

// MARK: - Timer Button

struct TimerButton: View {
    @ObservedObject var vm: SpeedViewModel
    @State private var isPressed = false

    var body: some View {
        Text(buttonLabel)
            .font(.system(size: 14, weight: .medium, design: .monospaced))
            .tracking(3)
            .foregroundColor(Theme.bg)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(buttonColor)
            )
            .opacity(shouldPulse ? (isPressed ? 0.6 : 1.0) : 1.0)
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .onPressGesture(
                onDown: {
                    isPressed = true
                    vm.onPressDown()
                },
                onUp: {
                    isPressed = false
                    vm.onPressUp()
                }
            )
            .animation(.easeInOut(duration: 0.1), value: isPressed)
    }

    private var buttonLabel: String {
        switch vm.triggerMode {
        case .classic:
            switch vm.phase {
            case .running: return "■  STOP"
            case .result: return "▶  AGAIN"
            default: return "▶  START"
            }
        case .release:
            switch vm.phase {
            case .armed: return "RELEASE TO START"
            case .running: return "■  STOP"
            default: return "HOLD TO ARM"
            }
        case .hold:
            switch vm.phase {
            case .running: return "RELEASE TO STOP"
            default: return "PRESS & HOLD"
            }
        }
    }

    private var buttonColor: Color {
        if vm.phase == .running { return Theme.red }
        if vm.phase == .armed { return Theme.purpleLight }
        return Theme.modeColor(vm.triggerMode)
    }

    private var shouldPulse: Bool {
        vm.phase == .armed || vm.phase == .running
    }
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
