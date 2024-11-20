//
//  RecipeDetailView.swift
//  Heron_RecipeApp
//
//  Created by Luci Feinberg on 11/13/24.
//

import SwiftUI

struct RecipeDetailView: View {
    let recipe: Recipe
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                AsyncImage(url: URL(string: recipe.thumbnail_url)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray
                }
                .frame(height: 200)
                .clipped()
                
                VStack(alignment: .leading, spacing: 16) {
                    Text(recipe.name)
                        .font(.title)
                        .bold()
                    
                    Text(recipe.description)
                        .font(.body)
                    
                    timeInformationView
                    
                    ingredientsSection
                    
                    instructionsSection
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var timeInformationView: some View {
        HStack(spacing: 20) {
            VStack {
                Text("Prep")
                Text("\(recipe.prep_time_minutes)min")
            }
            
            VStack {
                Text("Cook")
                Text("\(recipe.cook_time_minutes)min")
            }
            
            VStack {
                Text("Total")
                Text("\(recipe.total_time_minutes)min")
            }
        }
        .font(.subheadline)
    }
    
    private var ingredientsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Ingredients")
                .font(.title2)
                .bold()
            
            ForEach(recipe.sections, id: \.position) { section in
                if let name = section.name {
                    Text(name)
                        .font(.headline)
                }
                
                ForEach(section.components.indices, id: \.self) { index in
                    if section.components[index].raw_text.lowercased() != "n/a" {
                        Text("• \(section.components[index].raw_text)")
                    }
                }
            }
        }
    }
    
    private var instructionsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Instructions")
                .font(.title2)
                .bold()
            
            ForEach(recipe.instructions) { instruction in
                Text("\(instruction.position). \(instruction.display_text)")
                    .padding(.vertical, 4)
            }
        }
    }
}

struct RecipeDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RecipeDetailView(recipe: Recipe.preview)
        }
    }
}
