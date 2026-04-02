import SwiftUI

enum Theme {
    static let bg = Color(red: 0.04, green: 0.04, blue: 0.04)
    static let surface = Color(red: 0.07, green: 0.07, blue: 0.06)
    static let border = Color(red: 0.12, green: 0.11, blue: 0.10)
    static let borderSubtle = Color(red: 0.10, green: 0.10, blue: 0.09)
    static let textPrimary = Color(red: 0.88, green: 0.87, blue: 0.84)
    static let textSecondary = Color(red: 0.42, green: 0.41, blue: 0.38)
    static let textTertiary = Color(red: 0.23, green: 0.22, blue: 0.20)
    static let gold = Color(red: 0.96, green: 0.77, blue: 0.26)
    static let goldDim = Color(red: 0.77, green: 0.64, blue: 0.21)
    static let green = Color(red: 0.29, green: 0.87, blue: 0.50)
    static let red = Color(red: 0.97, green: 0.44, blue: 0.44)
    static let purple = Color(red: 0.66, green: 0.55, blue: 0.98)
    static let purpleLight = Color(red: 0.77, green: 0.71, blue: 0.99)
    static let blue = Color(red: 0.22, green: 0.74, blue: 0.97)

    static func modeColor(_ mode: TriggerMode) -> Color {
        switch mode {
        case .classic: return green
        case .release: return purple
        case .hold: return blue
        }
    }
}
