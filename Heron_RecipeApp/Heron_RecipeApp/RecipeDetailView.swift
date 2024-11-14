//
//  RecipeDetailView.swift
//  Heron_RecipeApp
//
//  Created by Luci Feinberg on 11/13/24.
//

import Foundation
import SwiftUI

struct RecipeDetailView: View {
    let recipeName: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(recipeName)
                .font(.largeTitle)
                .padding(.bottom, 10)
            
            Text("Ingredients")
                .font(.title2)
            
            Text("- Ingredient 1\n- Ingredient 2\n- Ingredient 3") // Placeholder ingredients
            
            Text("Instructions")
                .font(.title2)
                .padding(.top, 10)
            
            Text("1. Step one.\n2. Step two.\n3. Step three.") // Placeholder instructions
            
            Spacer()
        }
        .padding()
        .navigationTitle("Recipe Details")
    }
}

struct RecipeDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RecipeDetailView(recipeName: "Sample Recipe")
        }
    }
}
