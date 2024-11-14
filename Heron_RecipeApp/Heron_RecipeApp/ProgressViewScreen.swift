//
//  ProgressViewScreen.swift
//  Heron_RecipeApp
//
//  Created by Luci Feinberg on 11/13/24.
//

import SwiftUI

struct ProgressViewScreen: View {
    // State variable for controlling navigation
    @State private var navigateToRecipes = false
    
    var body: some View {
        VStack {
            Text("Progress")
                .font(.largeTitle)
            
            ProgressView("Loading Recipes...")
                .progressViewStyle(CircularProgressViewStyle())
                .padding()
            
            Spacer()
            
            // Simulate Done button
            Button(action: {
                navigateToRecipes = true // Trigger navigation to RecipeListView
            }) {
                Text("Simulate Done")
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            // Conditional NavigationLink triggered by navigateToRecipes
            .background(
                NavigationLink(destination: RecipeListView(), isActive: $navigateToRecipes) {
                    EmptyView()
                }
            )
        }
        .navigationTitle("Progress")
    }
}

struct ProgressViewScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProgressViewScreen()
        }
    }
}
