//
//  RecipeListView.swift
//  Heron_RecipeApp
//
//  Created by Luci Feinberg on 11/13/24.
//

import Foundation
import SwiftUI

struct RecipeListView: View {
    let recipes = ["Chicken & Mozzarella Bake", "Squash Curry", "Teriyaki Chicken", "Coconut & Squash Curry", "Spice Roasted Chicken"]
    
    var body: some View {
        List(recipes, id: \.self) { recipe in
            NavigationLink(destination: RecipeDetailView(recipeName: recipe)) {
                HStack {
                    Image(systemName: "photo") // Placeholder for recipe image
                    Text(recipe)
                }
            }
        }
        .navigationTitle("Recipes")
    }
}

struct RecipeListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RecipeListView()
        }
    }
}
