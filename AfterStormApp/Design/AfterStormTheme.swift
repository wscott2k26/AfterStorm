import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

enum AfterStormTheme {
    static let tiny: CGFloat = 6
    static let small: CGFloat = 10
    static let medium: CGFloat = 16
    static let large: CGFloat = 24
    static let xLarge: CGFloat = 34
    static let cornerRadius: CGFloat = 24
    static let compactRadius: CGFloat = 18

    static let deepSky = Color(red: 0.035, green: 0.055, blue: 0.10)
    static let stormBlue = Color(red: 0.12, green: 0.20, blue: 0.31)
    static let rainBlue = Color(red: 0.24, green: 0.49, blue: 0.67)
    static let afterglow = Color(red: 0.98, green: 0.72, blue: 0.34)
    static let spark = Color(red: 1.00, green: 0.82, blue: 0.36)
    static let restoredGreen = Color(red: 0.28, green: 0.65, blue: 0.46)

    static let premiumSpring = Animation.spring(response: 0.38, dampingFraction: 0.78)
    static let quickSpring = Animation.spring(response: 0.22, dampingFraction: 0.72)

    static var worldGradient: LinearGradient {
        LinearGradient(
            colors: [deepSky, stormBlue, rainBlue.opacity(0.72)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var afterglowGradient: LinearGradient {
        LinearGradient(
            colors: [afterglow.opacity(0.95), restoredGreen.opacity(0.72)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
