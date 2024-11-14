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
    
    func makeUIViewController(context: Context) -> VisionObjectRecognitionViewController {
        let viewController = VisionObjectRecognitionViewController()
        viewController.detectedFoods = detectedFoods
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: VisionObjectRecognitionViewController, context: Context) {
        uiViewController.detectedFoods = detectedFoods
    }
}
