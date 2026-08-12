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

    static let wetAsphalt = Color(red: 0.055, green: 0.072, blue: 0.095)
    static let wetReflection = Color(red: 0.20, green: 0.34, blue: 0.43)
    static let lanternWarm = Color(red: 1.00, green: 0.72, blue: 0.28)
    static let freshLeaf = Color(red: 0.31, green: 0.72, blue: 0.43)
    static let deepLeaf = Color(red: 0.12, green: 0.38, blue: 0.24)
    static let clearingSky = Color(red: 0.22, green: 0.42, blue: 0.58)
    static let afterglowSky = Color(red: 0.42, green: 0.39, blue: 0.48)
    static let duskRose = Color(red: 0.69, green: 0.39, blue: 0.38)

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
