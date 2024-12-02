//
//  ReceiptScannerView.swift
//  Heron_RecipeApp
//
//  Created by Luci Feinberg on 11/18/24.
//

import SwiftUI
import VisionKit
import Vision

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
        private var ingredientDictionary: [String: Int] = [:] // Store the parsed ingredient list

        init(detectedIngredients: Binding<[String]>, presentationMode: Binding<PresentationMode>) {
            _detectedIngredients = detectedIngredients
            self.presentationMode = presentationMode
            super.init() // Ensure the initializer chain is complete
            loadIngredientsFromCSV() // Call the method after `super.init()`
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

                // Extract detected words and filter against the ingredient dictionary
                let recognizedStrings = observations.compactMap { $0.topCandidates(1).first?.string.lowercased() }
                let matchingIngredients = recognizedStrings.filter { self?.ingredientDictionary.keys.contains($0) ?? false }

                // Log matching ingredients for debugging
                print("Matching ingredients: \(matchingIngredients)")

                DispatchQueue.main.async {
                    self?.detectedIngredients = Array(Set(matchingIngredients)) // Remove duplicates
                }
            }

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            try? handler.perform([request])
        }

        // Function to load and parse the CSV file into the ingredientDictionary
        private func loadIngredientsFromCSV() {
            guard let url = Bundle.main.url(forResource: "top-1k-ingredients", withExtension: "csv") else {
                print("CSV file not found!")
                return
            }

            do {
                let data = try String(contentsOf: url)
                var tempIngredients: [String: Int] = [:]

                // Split the file into lines and parse each line into key-value pairs
                let lines = data.split(separator: "\n")
                for line in lines {
                    let components = line.split(separator: ";")
                    if components.count == 2,
                       let ingredient = components.first?.trimmingCharacters(in: .whitespaces),
                       let countString = components.last?.trimmingCharacters(in: .whitespaces),
                       let count = Int(countString) {
                        tempIngredients[ingredient.lowercased()] = count
                    }
                }

                // Store the parsed dictionary into the instance variable
                self.ingredientDictionary = tempIngredients
            } catch {
                print("Error reading the CSV file: \(error.localizedDescription)")
            }
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
