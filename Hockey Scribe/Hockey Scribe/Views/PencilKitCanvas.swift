import SwiftUI
import PencilKit

struct PencilKitCanvas: UIViewRepresentable {
    var drawing: PKDrawing
    var onChanged: (PKDrawing) -> Void

    func makeUIView(context: Context) -> PKCanvasView {
        let canvas = PKCanvasView()
        canvas.backgroundColor = .clear
        canvas.isOpaque = false
        canvas.drawingPolicy = .anyInput
        canvas.tool = PKInkingTool(.marker, color: UIColor.white.withAlphaComponent(0.75), width: 15)
        canvas.delegate = context.coordinator
        return canvas
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        guard !context.coordinator.isUpdating, uiView.drawing != drawing else { return }
        context.coordinator.isUpdating = true
        uiView.drawing = drawing
        context.coordinator.isUpdating = false
    }

    func makeCoordinator() -> Coordinator { Coordinator(onChanged: onChanged) }

    class Coordinator: NSObject, PKCanvasViewDelegate {
        var onChanged: (PKDrawing) -> Void
        var isUpdating = false

        init(onChanged: @escaping (PKDrawing) -> Void) { self.onChanged = onChanged }

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            guard !isUpdating else { return }
            onChanged(canvasView.drawing)
        }
    }
}
