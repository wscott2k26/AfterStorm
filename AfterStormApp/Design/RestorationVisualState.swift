import SwiftUI

struct RestorationVisualState {
    let restorationFraction: Double

    init(restorationFraction: Double) {
        self.restorationFraction = min(1, max(0, restorationFraction))
    }

    var stormIntensity: Double { 1 - restorationFraction }
    var afterglowIntensity: Double { restorationFraction }
    var glowIntensity: Double { 0.24 + restorationFraction * 0.34 }

    var accentPrimary: Color {
        restorationFraction < 0.5 ? AfterStormTheme.rainBlue : AfterStormTheme.afterglow
    }

    var accentSecondary: Color {
        restorationFraction < 0.5 ? AfterStormTheme.stormBlue : AfterStormTheme.restoredGreen
    }

    var glassTint: Color {
        restorationFraction < 0.5 ? AfterStormTheme.deepSky : AfterStormTheme.afterglowSky
    }

    var backgroundColors: [Color] {
        if restorationFraction < 0.5 {
            return [AfterStormTheme.deepSky, AfterStormTheme.stormBlue, AfterStormTheme.rainBlue]
        }
        return [AfterStormTheme.deepSky, AfterStormTheme.clearingSky, AfterStormTheme.afterglowSky, AfterStormTheme.afterglow]
    }
}
