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
    
    var body: some View {
        VStack {
            Text("Camera View")
                .font(.largeTitle)
            
            Spacer()

            Button(action: {
                navigateToIngredients = true
            }) {
                Text("Take Picture")
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
            NavigationLink(destination: IngredientsView(), isActive: $navigateToIngredients) {
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
