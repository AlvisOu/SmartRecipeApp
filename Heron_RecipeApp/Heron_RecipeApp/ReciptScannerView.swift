//
//  ReciptScannerView.swift
//  Heron_RecipeApp
//
//  Created by  dam2274 on 11/25/24.
//

import SwiftUI
import VisionKit
import Vision

// Things we need to figure out
// 1. How can we test on our device?
// 2. Should we make API calls to spoonacular?
//    --
// 3. Integrate with the other parts of the app
// 4. Add image picker?

struct ReceiptScannerView: UIViewControllerRepresentable {
    @Binding var receiptIngredients: [String]
    @State private var knownIngredients: Set<String> = [] // Ingredients fetched from the API
    @Environment(\.presentationMode) var presentationMode // For navigation control
    
    private var apiKey: String = "6b836ec6cb864ff692260ac1fc585a93"
    
    // Add an explicit initializer
    public init(receiptIngredients: Binding<[String]>) {
        _receiptIngredients = receiptIngredients
    }
    
    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let scanner = VNDocumentCameraViewController()
        scanner.delegate = context.coordinator
        return scanner
    }

    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(receiptIngredients: $receiptIngredients, fetchIngredients: fetchIngredientList, presentationMode: presentationMode)
    }

    // Fetch ingredient list from the API
    func fetchIngredientList(completion: @escaping (Set<String>) -> Void) {
        let url = URL(string: "https://api.spoonacular.com/food/ingredients?apiKey=\(apiKey)")!
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching ingredients: \(error?.localizedDescription ?? "Unknown error")")
                completion([])
                return
            }

            do {
                let ingredients = try JSONDecoder().decode([String].self, from: data)
                completion(Set(ingredients.map { $0.lowercased() }))
            } catch {
                print("Error parsing ingredients: \(error.localizedDescription)")
                completion([])
            }
        }
        task.resume()
    }

    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        @Binding var receiptIngredients: [String]
        private var fetchIngredients: (@escaping (Set<String>) -> Void) -> Void
        private var knownIngredients: Set<String> = []
        private var presentationMode: Binding<PresentationMode>

        init(receiptIngredients: Binding<[String]>, fetchIngredients: @escaping (@escaping (Set<String>) -> Void) -> Void, presentationMode: Binding<PresentationMode>) {
            _receiptIngredients = receiptIngredients
            self.fetchIngredients = fetchIngredients
            self.presentationMode = presentationMode
        }

        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            fetchIngredients { [weak self] ingredients in
                self?.knownIngredients = ingredients

                for pageIndex in 0..<scan.pageCount {
                    let image = scan.imageOfPage(at: pageIndex)
                    self?.recognizeText(from: image)
                }

                // Automatically stop scanning after processing the receipt
                self?.presentationMode.wrappedValue.dismiss()
            }
        }

        private func recognizeText(from image: UIImage) {
            guard let cgImage = image.cgImage else { return }

            let request = VNRecognizeTextRequest { [weak self] (request, error) in
                guard let observations = request.results as? [VNRecognizedTextObservation] else { return }

                let recognizedStrings = observations.compactMap { $0.topCandidates(1).first?.string }

                let filteredIngredients = recognizedStrings
                    .map { $0.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { self?.knownIngredients.contains($0) ?? false }

                DispatchQueue.main.async {
                    self?.receiptIngredients.append(contentsOf: Set(filteredIngredients))
                }
            }

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            try? handler.perform([request])
        }
    }
}

struct ReceiptScannerContainerView: View {
    @State private var receiptIngredients: [String] = []
    @State private var navigateToIngredients = false

    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination: IngredientsView(ingredients: receiptIngredients), isActive: $navigateToIngredients) {
                    EmptyView()
                }

                Button(action: {
                    navigateToIngredients = true
                }) {
                    Text("Stop Scanning and Continue")
                        .font(.title2)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .sheet(isPresented: .constant(true)) {
                ReceiptScannerView(receiptIngredients: $receiptIngredients)
            }
        }
    }
}
