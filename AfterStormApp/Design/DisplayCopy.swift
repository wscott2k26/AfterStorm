import AfterStormCore

extension LifeArea {
    var displayName: String {
        switch self {
        case .home: "Home"
        case .work: "Work"
        case .focus: "Focus"
        case .digital: "Digital"
        case .movement: "Movement"
        case .learning: "Learning"
        case .lifeAdmin: "Life Admin"
        }
    }

    var symbolName: String {
        switch self {
        case .home: "house.fill"
        case .work: "briefcase.fill"
        case .focus: "scope"
        case .digital: "iphone.gen3"
        case .movement: "figure.walk"
        case .learning: "book.fill"
        case .lifeAdmin: "checklist"
        }
    }
}

extension AvatarStyle.Palette {
    var displayName: String {
        switch self {
        case .stormBlue: "Storm Blue"
        case .afterglow: "Afterglow"
        case .forest: "Forest"
        case .berry: "Berry"
        }
    }
}

extension AvatarStyle.Outfit {
    var displayName: String {
        switch self {
        case .classic: "Classic"
        case .fieldJacket: "Field Jacket"
        case .raincoat: "Raincoat"
        }
    }
}

extension AvatarStyle.Accessory {
    var displayName: String {
        switch self {
        case .none: "None"
        case .beanie: "Beanie"
        case .glasses: "Glasses"
        case .satchel: "Satchel"
        }
    }
}

extension AvatarStyle.SkinTone {
    var displayName: String {
        switch self { case .warmLight: "Warm Light"; case .golden: "Golden"; case .brown: "Brown"; case .deep: "Deep" }
    }
}

extension AvatarStyle.HairStyle {
    var displayName: String {
        switch self { case .cropped: "Cropped"; case .curls: "Curls"; case .waves: "Waves"; case .locs: "Locs" }
    }
}

extension AvatarStyle.EyeStyle {
    var displayName: String {
        switch self { case .bright: "Bright"; case .calm: "Calm"; case .bold: "Bold" }
    }
}

extension AvatarStyle.StormlingBody {
    var displayName: String {
        switch self { case .smooth: "Smooth"; case .fluffy: "Fluffy"; case .rainSpeckled: "Rain Speckled" }
    }
}

extension AvatarStyle.HeadShape {
    var displayName: String {
        switch self { case .round: "Round"; case .softSquare: "Soft Square"; case .tall: "Tall" }
    }
}
