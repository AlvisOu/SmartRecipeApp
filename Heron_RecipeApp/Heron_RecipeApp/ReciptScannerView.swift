//
//  ReceiptScannerView.swift
//  Heron_RecipeApp
//
//  Created by Luci Feinberg on 11/18/24.
//

import SwiftUI
import VisionKit
import Vision

// Things we need to figure out
// 1. How can we test on our device?
// 2. Should we make API calls to spoonacular?
// 3. Integrate with the other parts of the app
// 4. Add image picker?

struct ReceiptScannerView: UIViewControllerRepresentable {
    @Binding var detectedIngredients: [String] // Bind to detected ingredients
    @Environment(\.presentationMode) var presentationMode // For dismissing the scanner

    public init(detectedIngredients: Binding<[String]>) {
        _detectedIngredients = detectedIngredients
    }

    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let scanner = VNDocumentCameraViewController()
        scanner.delegate = context.coordinator
        return scanner
    }

    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(detectedIngredients: $detectedIngredients, presentationMode: presentationMode)
    }

    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        @Binding var detectedIngredients: [String]
        private var presentationMode: Binding<PresentationMode>
        private let ingredients = ["potato", "beet", "carrot", "chicken", "beef", "sugar", "egg", "cooking oil"] // Predefined list
        
        //Add initalize ingredients list here!!

        init(detectedIngredients: Binding<[String]>, presentationMode: Binding<PresentationMode>) {
            _detectedIngredients = detectedIngredients
            self.presentationMode = presentationMode
        }

        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            for pageIndex in 0..<scan.pageCount {
                let image = scan.imageOfPage(at: pageIndex)
                recognizeText(from: image)
            }

            // Dismiss scanner after processing
            presentationMode.wrappedValue.dismiss()
        }

        private func recognizeText(from image: UIImage) {
            guard let cgImage = image.cgImage else { return }

            let request = VNRecognizeTextRequest { [weak self] (request, error) in
                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    print("No text found")
                    return
                }

                // Extract detected words and filter against the ingredients list
                let recognizedStrings = observations.compactMap { $0.topCandidates(1).first?.string.lowercased() }
                let matchingIngredients = recognizedStrings.filter { self?.ingredients.contains($0) ?? false }

                // Log matching ingredients for debugging
                print("Matching ingredients: \(matchingIngredients)")

                DispatchQueue.main.async {
                    self?.detectedIngredients = matchingIngredients
                }
            }

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            try? handler.perform([request])
        }
    }
}

struct ReceiptScannerContainerView: View {
    @State private var detectedIngredients: [String] = [] // Detected ingredients
    @State private var navigateToIngredients = false // Trigger navigation to IngredientsView
    @State private var isScannerPresented = false // Scanner initially closed

    var body: some View {
        VStack {
            // Show detected ingredients for review
            if !detectedIngredients.isEmpty {
                List(detectedIngredients, id: \.self) { ingredient in
                    Text(ingredient.capitalized)
                }
            } else {
                Text("Scan a receipt to detect ingredients.")
                    .foregroundColor(.gray)
                    .padding()
            }

            HStack {
                // Button to navigate to IngredientsView
                Button(action: {
                    navigateToIngredients = true
                }) {
                    Text("View Ingredients")
                        .font(.title2)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                }
                .disabled(detectedIngredients.isEmpty) // Disable button if no ingredients are detected

                // Launch Scanner Again
                Button(action: {
                    isScannerPresented = true // Relaunch scanner
                }) {
                    Text("Scan Again")
                        .font(.title2)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                }
            }
        }
        .navigationTitle("Scan Receipt")
        // Attach the navigation link to the VStack's background
        .background(
            NavigationLink(
                destination: IngredientsView(ingredients: detectedIngredients),
                isActive: $navigateToIngredients
            ) {
                EmptyView()
            }
        )
        // Automatically show scanner on view load
        .onAppear {
            isScannerPresented = true
        }
        .sheet(isPresented: $isScannerPresented) {
            ReceiptScannerView(detectedIngredients: $detectedIngredients)
        }
    }
}

