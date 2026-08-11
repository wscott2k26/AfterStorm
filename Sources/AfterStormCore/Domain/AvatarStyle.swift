import Foundation

public struct AvatarStyle: Equatable, Codable, Sendable {
    public enum Palette: String, CaseIterable, Codable, Sendable {
        case stormBlue, afterglow, forest, berry
    }

    public enum Outfit: String, CaseIterable, Codable, Sendable {
        case classic, fieldJacket, raincoat
    }

    public enum Accessory: String, CaseIterable, Codable, Sendable {
        case none, beanie, glasses, satchel
    }

    public enum SkinTone: String, CaseIterable, Codable, Sendable {
        case warmLight, golden, brown, deep
    }

    public enum HairStyle: String, CaseIterable, Codable, Sendable {
        case cropped, curls, waves, locs
    }

    public enum EyeStyle: String, CaseIterable, Codable, Sendable {
        case bright, calm, bold
    }

    public enum StormlingBody: String, CaseIterable, Codable, Sendable {
        case smooth, fluffy, rainSpeckled
    }

    public enum HeadShape: String, CaseIterable, Codable, Sendable {
        case round, softSquare, tall
    }

    public var palette: Palette
    public var outfit: Outfit
    public var accessory: Accessory
    public var skinTone: SkinTone
    public var hairStyle: HairStyle
    public var eyeStyle: EyeStyle
    public var stormlingBody: StormlingBody
    public var headShape: HeadShape

    public init(
        palette: Palette = .stormBlue,
        outfit: Outfit = .classic,
        accessory: Accessory = .none,
        skinTone: SkinTone = .golden,
        hairStyle: HairStyle = .cropped,
        eyeStyle: EyeStyle = .bright,
        stormlingBody: StormlingBody = .smooth,
        headShape: HeadShape = .round
    ) {
        self.palette = palette
        self.outfit = outfit
        self.accessory = accessory
        self.skinTone = skinTone
        self.hairStyle = hairStyle
        self.eyeStyle = eyeStyle
        self.stormlingBody = stormlingBody
        self.headShape = headShape
    }

    private enum CodingKeys: String, CodingKey {
        case palette, outfit, accessory, skinTone, hairStyle, eyeStyle, stormlingBody, headShape
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        palette = try container.decodeIfPresent(Palette.self, forKey: .palette) ?? .stormBlue
        outfit = try container.decodeIfPresent(Outfit.self, forKey: .outfit) ?? .classic
        accessory = try container.decodeIfPresent(Accessory.self, forKey: .accessory) ?? .none
        skinTone = try container.decodeIfPresent(SkinTone.self, forKey: .skinTone) ?? .golden
        hairStyle = try container.decodeIfPresent(HairStyle.self, forKey: .hairStyle) ?? .cropped
        eyeStyle = try container.decodeIfPresent(EyeStyle.self, forKey: .eyeStyle) ?? .bright
        stormlingBody = try container.decodeIfPresent(StormlingBody.self, forKey: .stormlingBody) ?? .smooth
        headShape = try container.decodeIfPresent(HeadShape.self, forKey: .headShape) ?? .round
    }

    public static let `default` = AvatarStyle()
}
