//
//  IngredientsView.swift
//  Heron_RecipeApp
//
//  Created by Luci Feinberg on 11/13/24.
//

import SwiftUI

struct IngredientsView: View {
    @State private var ingredients = ["Tomato", "Onion", "Carrot", "Chicken", "water" , "Broccoli"]
    @State private var navigateToProgress = false // State variable for navigation
    
    var body: some View {
        VStack {
            Text("Ingredients")
                .font(.largeTitle)
            
            List {
                ForEach(ingredients, id: \.self) { ingredient in
                    Text(ingredient)
                }
            }
            
            Spacer()
            
            // Button to navigate to ProgressViewScreen
            Button(action: {
                navigateToProgress = true
            }) {
                Text("Let's Cook a Recipe")
                    .font(.title2)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal, 20)
            }
            
            // Navigation link triggered by the button action
            .background(
                NavigationLink(destination: ProgressViewScreen(), isActive: $navigateToProgress) {
                    EmptyView()
                }
            )
        }
        .navigationTitle("Ingredients List")
    }
}

struct IngredientsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            IngredientsView()
        }
    }
}
