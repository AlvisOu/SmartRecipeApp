//
//  CameraView.swift
//  Heron_RecipeApp
//
//  Created by Luci Feinberg on 11/13/24.
//

import SwiftUI

struct CameraView: View {
    // State variable to trigger navigation
    @State private var navigateToIngredients = false
    @State private var detectedFoods: [String] = []
    @State private var cameraViewController: VisionObjectRecognitionViewController?
    
    var body: some View {
        VStack {
            Text("Camera View")
                .font(.largeTitle)
            
            Spacer()
            
            // Display the camera feed
            VisionObjectRecognitionView(
                detectedFoods: $detectedFoods,
                onReset: {
                detectedFoods = []},
                onViewControllerCreated: { viewController in
                    cameraViewController = viewController
                })
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            HStack{
                Button(action: {
                    navigateToIngredients = true
                }) {
                    Text("Stop scanning")
                        .font(.title)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Button(action: {
                    detectedFoods = []
                }) {
                    Text("Reset ingredients")
                        .font(.title)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }

            Spacer()
        }
        .navigationTitle("Camera")
        // Navigation link tied to the state variable
        .background(
            NavigationLink(destination: IngredientsView(ingredients: detectedFoods), isActive: $navigateToIngredients) {
                EmptyView()
            }
        )
        
        .onDisappear {
            if let viewController = cameraViewController {
                VisionObjectRecognitionView.stopSession(viewController: viewController)
            }
        }
        .onAppear {
            if let viewController = cameraViewController {
                VisionObjectRecognitionView.restartSession(viewController: viewController)
            }
        }
        
    }
}

struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CameraView()
        }
    }
}
