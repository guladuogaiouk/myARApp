//
//  ContentView.swift
//  myARApp
//
//  Created by Tianyu Xu on 2024/6/14.
//

import SwiftUI
import ARKit
import RealityKit
import Vision

struct ContentView: View {
    @StateObject private var viewModel = ViewModel()

    var body: some View {
        ZStack {
            ARViewContainer(viewModel: viewModel).edgesIgnoringSafeArea(.all)
            HStack {
                Button(action: {
                    viewModel.captureAndRecognizeText()
                }) {
                    Image(systemName: "camera.fill")
                        .font(.largeTitle)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                }
                .padding()
            }
        }
    }
}

struct ARViewContainer: UIViewRepresentable {
    @ObservedObject var viewModel: ContentView.ViewModel

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        let coordinator = context.coordinator
        arView.session.delegate = coordinator
        let configuration = ARWorldTrackingConfiguration()
        arView.session.run(configuration)
        coordinator.arView = arView
        viewModel.coordinator = coordinator
        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, ARSessionDelegate {
        var parent: ARViewContainer
        var arView: ARView?

        init(_ parent: ARViewContainer) {
            self.parent = parent
        }

        func session(_ session: ARSession, didUpdate frame: ARFrame) {
            // No need to perform OCR here anymore
        }

        func recognizeText(in image: CIImage, recognitionLevel: VNRequestTextRecognitionLevel = .accurate, usesLanguageCorrection: Bool = true, completion: @escaping ([String]) -> Void) {
            DispatchQueue.global(qos: .userInitiated).async {
                let requestHandler = VNImageRequestHandler(ciImage: image, options: [:])
                let request = VNRecognizeTextRequest { (request, error) in
                    var recognizedTexts = [String]()
                    
                    if let observations = request.results as? [VNRecognizedTextObservation] {
                        for observation in observations {
                            if let bestCandidate = observation.topCandidates(1).first {
                                recognizedTexts.append(bestCandidate.string)
                            }
                        }
                    }
                    DispatchQueue.main.async {
                        completion(recognizedTexts)
                    }
                }
                
                request.recognitionLevel = recognitionLevel
                request.usesLanguageCorrection = usesLanguageCorrection

                do {
                    try requestHandler.perform([request])
                } catch {
                    print("Failed to perform text recognition: \(error)")
                    DispatchQueue.main.async {
                        completion([])
                    }
                }
            }
        }
    }
}

extension ContentView {
    class ViewModel: ObservableObject {
        weak var coordinator: ARViewContainer.Coordinator?

        func captureAndRecognizeText() {
//            guard let coordinator = coordinator else { return }
//            guard let frame = coordinator.arView?.session.currentFrame else { return }
//            let image = CIImage(cvPixelBuffer: frame.capturedImage)
            guard let uiImage = UIImage(named: "1.jpg") else {
                    print("Image not found")
                    return
                }
                
            guard let ciImage = CIImage(image: uiImage) else {
                print("Failed to create CIImage")
                return
            }
            
            coordinator?.recognizeText(in: ciImage) { recognizedTexts in
                print("Recognized texts: \(recognizedTexts)")
            }
            coordinator?.recognizeText(in: CIImage(image: processImage(inputImage: uiImage)!)!) { recognizedTexts in
                print("Recognized texts: \(recognizedTexts)")
            }
        }
    }
}

