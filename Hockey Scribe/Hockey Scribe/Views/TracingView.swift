import SwiftUI
import PencilKit
import AVFoundation
import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins

struct TracingView: View {
    @EnvironmentObject var appState: AppState
    let team: NHLTeam
    let word: String
    var headerImageURL: URL? = nil

    @State private var currentIndex = 0
    @State private var drawing = PKDrawing()
    @State private var inactivityTimer: Timer?
    @State private var synthesizer = AVSpeechSynthesizer()
    @State private var speechDelegate = TracingSpeechDelegate()
    @State private var completedIndices: Set<Int> = []
    @State private var canvasSize: CGSize = .zero
    @State private var letterFrames: [Int: CGRect] = [:]
    @State private var letterMasks: [Int: LetterCoverageMask] = [:]
    @State private var strokeAttribution: [Int: Int] = [:]
    @Environment(\.displayScale) private var displayScale

    private let coverageThreshold: CGFloat = 0.30
    private let fallbackInactivity: TimeInterval = 1.5

    private var letters: [Character] { Array(word) }
    private var currentLetter: Character { letters[currentIndex] }

    private var fontSize: CGFloat {
        let count = letters.count
        return max(90, 260 - CGFloat(count - 3) * 22)
    }


    var body: some View {
        ZStack {
            team.primarySwiftUIColor.ignoresSafeArea()
            Color.clear
                .onGeometryChange(for: CGSize.self) { $0.size } action: { canvasSize = $0 }

            VStack(spacing: 0) {
                if let url = headerImageURL {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().scaledToFill()
                        default:
                            Color.clear
                        }
                    }
                    .frame(width: 720, height: 405)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .shadow(color: .black.opacity(0.35), radius: 12, y: 4)
                    .padding(.top, 36)
                } else {
                    Image(team.logoAssetName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 560, height: 560)
                        .padding(.top, 36)
                }

                Spacer()

                HStack(spacing: 8) {
                    ForEach(Array(letters.enumerated()), id: \.offset) { i, letter in
                        Text(String(letter))
                            .font(.custom("TeachingPrintDottedLined", size: fontSize))
                            .foregroundColor(letterColor(for: i))
                            .scaleEffect(i == currentIndex ? 1.08 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: currentIndex)
                            .animation(.easeInOut(duration: 0.3), value: completedIndices)
                            .onGeometryChange(for: CGRect.self) {
                                $0.frame(in: .global)
                            } action: { newFrame in
                                if letterFrames[i] != newFrame {
                                    letterFrames[i] = newFrame
                                    letterMasks[i] = nil
                                }
                            }
                    }
                }

                Spacer()

                Text("Trace the \(String(currentLetter))!")
                    .font(.system(size: 26, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.bottom, 48)
            }

            PencilKitCanvas(drawing: drawing) { newDrawing in
                drawing = newDrawing
                handleDrawingChange()
            }
            .ignoresSafeArea()
        }
        .onAppear {
            synthesizer.delegate = speechDelegate
        }
        .onDisappear {
            inactivityTimer?.invalidate()
            synthesizer.stopSpeaking(at: .immediate)
            speechDelegate.reset()
        }
    }

    private func letterColor(for index: Int) -> Color {
        if completedIndices.contains(index) {
            return team.secondarySwiftUIColor
        } else if index == currentIndex {
            return .white
        } else {
            return .white.opacity(0.35)
        }
    }

    // MARK: - Drawing pipeline

    private func handleDrawingChange() {
        attributeNewStrokes()
        evaluateCurrentLetter()
        scheduleInactivityFallback()
    }

    private func attributeNewStrokes() {
        for idx in 0..<drawing.strokes.count where strokeAttribution[idx] == nil {
            if let letterIdx = dominantLetter(for: drawing.strokes[idx]) {
                strokeAttribution[idx] = letterIdx
            }
        }
    }

    /// Returns the letter index whose horizontal position best matches the
    /// majority of the stroke's points. Only points that fall inside the
    /// vertical band of the letter row are considered.
    private func dominantLetter(for stroke: PKStroke) -> Int? {
        guard !letterFrames.isEmpty else { return nil }
        guard let minY = letterFrames.values.map(\.minY).min(),
              let maxY = letterFrames.values.map(\.maxY).max() else { return nil }
        let bandPad: CGFloat = 24

        var counts: [Int: Int] = [:]
        let pathCount = stroke.path.count
        guard pathCount > 0 else { return nil }
        let step = max(1, pathCount / 30)

        for (i, point) in stroke.path.enumerated() {
            guard i % step == 0 else { continue }
            let pt = point.location
            if pt.y < minY - bandPad || pt.y > maxY + bandPad { continue }
            if let nearest = letterFrames.min(by: {
                abs($0.value.midX - pt.x) < abs($1.value.midX - pt.x)
            }) {
                counts[nearest.key, default: 0] += 1
            }
        }
        return counts.max(by: { $0.value < $1.value })?.key
    }

    private func evaluateCurrentLetter() {
        guard currentIndex < letters.count else { return }
        attributeNewStrokes()
        guard let frame = letterFrames[currentIndex] else { return }

        let strokeIndices = strokeAttribution
            .filter { $0.value == currentIndex }
            .map(\.key)
        guard !strokeIndices.isEmpty else { return }

        let strokes = strokeIndices.compactMap { idx -> PKStroke? in
            idx < drawing.strokes.count ? drawing.strokes[idx] : nil
        }
        let mask = letterMask(for: currentIndex, in: frame)
        let coverage = LetterCoverageMask.coverage(strokes: strokes, in: frame, mask: mask)

        if coverage >= coverageThreshold {
            advanceCurrentLetter()
        }
    }

    private func advanceCurrentLetter() {
        guard currentIndex < letters.count, !completedIndices.contains(currentIndex) else { return }
        inactivityTimer?.invalidate()

        speakPhonics(for: currentLetter)
        completedIndices.insert(currentIndex)

        if currentIndex + 1 < letters.count {
            currentIndex += 1
            // Catch up instantly if Teddy already wrote into the next letter.
            evaluateCurrentLetter()
        } else {
            let nextPhase: SessionPhase
            switch appState.sessionPhase {
            case .goalieTracing: nextPhase = .goalCelebration
            case .scorerTracing: nextPhase = .scorerCelebration
            default:             nextPhase = .celebration
            }
            // Transition exactly when the word utterance finishes — keeps the
            // queued phonics + word intact even when the system was catching up
            // through several letters at once.
            speakWord {
                appState.tracingSnapshot = drawing.image(
                    from: CGRect(origin: .zero, size: canvasSize),
                    scale: displayScale
                )
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    appState.sessionPhase = nextPhase
                }
            }
        }
    }

    private func scheduleInactivityFallback() {
        inactivityTimer?.invalidate()
        inactivityTimer = Timer.scheduledTimer(withTimeInterval: fallbackInactivity, repeats: false) { _ in
            DispatchQueue.main.async {
                fireInactivityFallback()
            }
        }
    }

    /// Apply the "any-strokes" advance rule, then keep applying it as the system
    /// cascades forward — so if Teddy raced past several letters before pausing,
    /// one fallback fire catches the whole chain instead of stalling 1.5s per letter.
    private func fireInactivityFallback() {
        attributeNewStrokes()
        // Misattribution rescue for the last letter only applies if we ENTERED the
        // fallback already sitting on the last letter (Teddy paused there for 1.5s).
        // If we're cascading INTO the last letter from earlier letters, he hasn't
        // gotten there yet — don't skip past it.
        let allowLastLetterRescue = currentIndex == letters.count - 1
        var safety = letters.count + 1
        while currentIndex < letters.count,
              !completedIndices.contains(letters.count - 1),
              safety > 0 {
            safety -= 1
            let priorIndex = currentIndex
            let hasStrokes = strokeAttribution.values.contains(currentIndex)
            let isLastLetter = currentIndex == letters.count - 1
            let lastLetterRescue = isLastLetter && allowLastLetterRescue && !drawing.strokes.isEmpty
            guard hasStrokes || lastLetterRescue else { break }
            advanceCurrentLetter()
            if currentIndex == priorIndex && !completedIndices.contains(letters.count - 1) { break }
        }
    }

    private func letterMask(for index: Int, in frame: CGRect) -> LetterCoverageMask {
        if let cached = letterMasks[index] { return cached }
        let mask = LetterCoverageMask.make(letter: letters[index], frame: frame, fontSize: fontSize)
        letterMasks[index] = mask
        return mask
    }

    private func speakPhonics(for letter: Character) {
        let utterance = AVSpeechUtterance(string: String(letter).lowercased())
        utterance.rate = 0.38
        utterance.pitchMultiplier = 1.2
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        synthesizer.speak(utterance)
    }

    private func speakWord(then completion: @escaping () -> Void) {
        let utterance = AVSpeechUtterance(string: word)
        utterance.rate = 0.45
        utterance.pitchMultiplier = 1.15
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        speechDelegate.awaitCompletion(of: utterance, then: completion)
        synthesizer.speak(utterance)
    }
}

// MARK: - Letter coverage mask

struct LetterCoverageMask {
    let pixels: [UInt8]
    let width: Int
    let height: Int
    let totalOn: Int

    private static let renderScale: CGFloat = 0.2
    private static let userStrokeWidth: CGFloat = 15
    private static let dilateRadius: Double = 12.0
    private static let onThreshold: UInt8 = 32
    private static let ciContext = CIContext(options: nil)

    static func make(letter: Character, frame: CGRect, fontSize: CGFloat) -> LetterCoverageMask {
        let w = max(1, Int(frame.width * renderScale))
        let h = max(1, Int(frame.height * renderScale))
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: w, height: h))
        let glyph = renderer.image { _ in
            let font = UIFont(name: "TeachingPrintDottedLined", size: fontSize * renderScale)
                ?? UIFont.systemFont(ofSize: fontSize * renderScale, weight: .black)
            let attrs: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: UIColor.black
            ]
            let str = NSAttributedString(string: String(letter), attributes: attrs)
            let glyphSize = str.size()
            let rect = CGRect(
                x: (CGFloat(w) - glyphSize.width) / 2,
                y: (CGFloat(h) - glyphSize.height) / 2,
                width: glyphSize.width,
                height: glyphSize.height
            )
            str.draw(in: rect)
        }
        let dilated = dilatedAlpha(of: glyph) ?? alphaPixels(of: glyph)
        let totalOn = dilated.reduce(0) { $0 + ($1 > onThreshold ? 1 : 0) }
        return LetterCoverageMask(pixels: dilated, width: w, height: h, totalOn: totalOn)
    }

    static func coverage(strokes: [PKStroke], in frame: CGRect, mask: LetterCoverageMask) -> CGFloat {
        guard mask.totalOn > 0 else { return 0 }
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: mask.width, height: mask.height))
        let stroked = renderer.image { ctx in
            let cg = ctx.cgContext
            cg.setStrokeColor(UIColor.black.cgColor)
            cg.setLineCap(.round)
            cg.setLineJoin(.round)
            cg.setLineWidth(userStrokeWidth * renderScale)
            for stroke in strokes {
                guard stroke.path.count > 0 else { continue }
                cg.beginPath()
                var first = true
                for point in stroke.path {
                    let pt = point.location
                    let x = (pt.x - frame.minX) * renderScale
                    let y = (pt.y - frame.minY) * renderScale
                    if first {
                        cg.move(to: CGPoint(x: x, y: y))
                        first = false
                    } else {
                        cg.addLine(to: CGPoint(x: x, y: y))
                    }
                }
                cg.strokePath()
            }
        }
        let user = alphaPixels(of: stroked)
        let count = min(user.count, mask.pixels.count)
        var overlap = 0
        for i in 0..<count {
            if user[i] > onThreshold && mask.pixels[i] > onThreshold {
                overlap += 1
            }
        }
        return CGFloat(overlap) / CGFloat(mask.totalOn)
    }

    private static func alphaPixels(of image: UIImage) -> [UInt8] {
        guard let cg = image.cgImage else { return [] }
        let w = cg.width
        let h = cg.height
        var data = [UInt8](repeating: 0, count: w * h)
        guard let ctx = CGContext(
            data: &data,
            width: w, height: h,
            bitsPerComponent: 8,
            bytesPerRow: w,
            space: CGColorSpaceCreateDeviceGray(),
            bitmapInfo: CGImageAlphaInfo.alphaOnly.rawValue
        ) else { return data }
        ctx.draw(cg, in: CGRect(x: 0, y: 0, width: w, height: h))
        return data
    }

    private static func dilatedAlpha(of image: UIImage) -> [UInt8]? {
        guard let cg = image.cgImage else { return nil }
        let ciImage = CIImage(cgImage: cg)
        let blur = CIFilter.gaussianBlur()
        blur.inputImage = ciImage
        blur.radius = Float(dilateRadius)
        guard let output = blur.outputImage,
              let cgOut = ciContext.createCGImage(output, from: ciImage.extent) else { return nil }
        return alphaPixels(of: UIImage(cgImage: cgOut))
    }
}

// MARK: - Speech completion delegate

/// Lets the view know precisely when a specific utterance has finished
/// speaking — needed because the synthesizer queues many phonics utterances
/// in front of the final word, and a fixed delay can't predict that.
final class TracingSpeechDelegate: NSObject, AVSpeechSynthesizerDelegate {
    private var finalUtterance: AVSpeechUtterance?
    private var onFinalComplete: (() -> Void)?

    func awaitCompletion(of utterance: AVSpeechUtterance, then completion: @escaping () -> Void) {
        finalUtterance = utterance
        onFinalComplete = completion
    }

    func reset() {
        finalUtterance = nil
        onFinalComplete = nil
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        guard utterance === finalUtterance else { return }
        let cb = onFinalComplete
        finalUtterance = nil
        onFinalComplete = nil
        DispatchQueue.main.async { cb?() }
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        guard utterance === finalUtterance else { return }
        finalUtterance = nil
        onFinalComplete = nil
    }
}

#Preview {
    TracingView(team: allNHLTeams[0], word: allNHLTeams[0].nickname)
        .environmentObject(AppState())
}
