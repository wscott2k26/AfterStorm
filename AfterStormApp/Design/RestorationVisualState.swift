import SwiftUI

struct RestorationVisualState: Equatable {
    let restorationFraction: Double

    init(restorationFraction: Double) {
        self.restorationFraction = min(1, max(0, restorationFraction))
    }

    var stormWeight: Double { clamp(1.0 - restorationFraction * 1.35) }
    var clearingWeight: Double { clamp(1.0 - abs(restorationFraction - 0.5) * 2.0) }
    var afterglowWeight: Double { clamp((restorationFraction - 0.42) / 0.58) }

    var stormIntensity: Double { stormWeight }
    var afterglowIntensity: Double { afterglowWeight }
    var glowIntensity: Double { 0.28 + clearingWeight * 0.16 + afterglowWeight * 0.30 }
    var glassOpacity: Double { 0.46 - afterglowWeight * 0.13 }

    var accentPrimary: Color {
        interpolatedColor(
            early: RGB(0.24, 0.62, 0.94),
            middle: RGB(0.18, 0.70, 0.72),
            late: RGB(1.00, 0.82, 0.36)
        )
    }

    var accentSecondary: Color {
        interpolatedColor(
            early: RGB(0.24, 0.49, 0.67),
            middle: RGB(0.72, 0.82, 0.88),
            late: RGB(0.98, 0.72, 0.34)
        )
    }

    var glassTint: Color {
        interpolatedColor(
            early: RGB(0.035, 0.055, 0.10),
            middle: RGB(0.22, 0.42, 0.58),
            late: RGB(0.42, 0.39, 0.48)
        )
    }

    var backgroundColors: [Color] {
        [
            AfterStormTheme.deepSky,
            AfterStormTheme.stormBlue.opacity(0.70 + stormWeight * 0.28),
            AfterStormTheme.stormTeal.opacity(0.12 + clearingWeight * 0.48),
            AfterStormTheme.clearingSky.opacity(0.15 + clearingWeight * 0.52),
            AfterStormTheme.afterglowRose.opacity(afterglowWeight * 0.34),
            AfterStormTheme.afterglow.opacity(afterglowWeight * 0.30)
        ]
    }

    private func clamp(_ value: Double) -> Double {
        min(1, max(0, value))
    }

    private func interpolatedColor(early: RGB, middle: RGB, late: RGB) -> Color {
        let value: RGB
        if restorationFraction <= 0.5 {
            value = early.mixed(with: middle, amount: restorationFraction / 0.5)
        } else {
            value = middle.mixed(with: late, amount: (restorationFraction - 0.5) / 0.5)
        }
        return value.color
    }

    private struct RGB: Equatable {
        let red: Double
        let green: Double
        let blue: Double

        init(_ red: Double, _ green: Double, _ blue: Double) {
            self.red = red
            self.green = green
            self.blue = blue
        }

        func mixed(with other: RGB, amount: Double) -> RGB {
            let t = min(1, max(0, amount))
            return RGB(
                red + (other.red - red) * t,
                green + (other.green - green) * t,
                blue + (other.blue - blue) * t
            )
        }

        var color: Color {
            Color(red: red, green: green, blue: blue)
        }
    }
}
