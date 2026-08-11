import CoreGraphics
import UIKit
import Vision

actor SceneAnalysisService {
    private let apple = AppleIntelligenceQuestService()

    func describe(_ image: UIImage) async -> String {
        guard let cgImage = image.cgImage else { return "A photo the user wants help turning into a small quest." }

        if #available(iOS 27.0, *), let description = try? await apple.sceneDescription(for: cgImage), !description.isEmpty {
            return description
        }

        let recognized = recognizeText(in: cgImage)
        if !recognized.isEmpty {
            return "The image contains visible text or labels: \(recognized.prefix(10).joined(separator: ", ")). Suggest a small task using this scene."
        }
        return "The user shared a photo of their current environment and wants one small, respectful task they can do there."
    }

    private func recognizeText(in image: CGImage) -> [String] {
        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .fast
        request.usesLanguageCorrection = true
        let handler = VNImageRequestHandler(cgImage: image)
        do {
            try handler.perform([request])
            return (request.results ?? []).compactMap { $0.topCandidates(1).first?.string }
        } catch {
            return []
        }
    }
}
