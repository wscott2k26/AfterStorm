import SwiftUI

private struct AfterStormVisualStateKey: EnvironmentKey {
    static let defaultValue = RestorationVisualState(restorationFraction: 0)
}

extension EnvironmentValues {
    var afterStormVisualState: RestorationVisualState {
        get { self[AfterStormVisualStateKey.self] }
        set { self[AfterStormVisualStateKey.self] = newValue }
    }
}
