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
    
    var body: some View {
        VStack {
            Text("Camera View")
                .font(.largeTitle)
            
            Text(detectedFoods.isEmpty ? "No foods detected" : detectedFoods.joined(separator: "\n"))
                .font(.title2)
                .padding()
                .foregroundColor(detectedFoods.isEmpty ? .gray : .black)
                .multilineTextAlignment(.center)
                .onChange(of: detectedFoods) { newValue in
                    print("CameraView detectedFoods updated: \(newValue)")
                }
            Spacer()
            
            // Display the camera feed
            VisionObjectRecognitionView(detectedFoods: $detectedFoods).frame(maxWidth: .infinity, maxHeight: .infinity)

            Button(action: {
                navigateToIngredients = true
            }) {
                Text("Stop scanning")
                    .font(.title)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
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
    }
}

struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CameraView()
        }
    }
}
