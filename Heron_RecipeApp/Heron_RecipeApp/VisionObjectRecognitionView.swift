//
//  VisionObjectRecognitionView.swift
//  Heron_RecipeApp
//
//  Created by  ao2844 on 11/14/24.
//

import SwiftUI
import Foundation
struct VisionObjectRecognitionView: UIViewControllerRepresentable {
    @Binding var detectedFoods: [String]
    var onReset: () -> Void
    var onViewControllerCreated: (VisionObjectRecognitionViewController) -> Void
    
    class Coordinator: NSObject, ObservableObject {
        @Published var detectedFoods: [String] = [] {
            didSet {
                print("Coordinator detectedFoods updated: \(detectedFoods)")
            }
        }
        override init() {
            super.init()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func makeUIViewController(context: Context) -> VisionObjectRecognitionViewController {
        let viewController = VisionObjectRecognitionViewController()
        
        viewController.onFoodsDetected = { foods in
            DispatchQueue.main.async {
                self.detectedFoods = foods
                print("VisionObjectRecognitionView detectedFoods updated: \(foods)")
            }
        }
        
        DispatchQueue.main.async {
                self.onViewControllerCreated(viewController)
            }

        return viewController
    }
    
    func updateUIViewController(_ uiViewController: VisionObjectRecognitionViewController, context: Context) {
    }
    
    static func stopSession(viewController: VisionObjectRecognitionViewController) {
        viewController.stopSession()
        print("Stopping session")
    }
        
    static func restartSession(viewController: VisionObjectRecognitionViewController) {
        viewController.setupAVCapture()
    }
    
}
