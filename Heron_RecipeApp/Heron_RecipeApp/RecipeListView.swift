//
//  RecipeListView.swift
//  Heron_RecipeApp
//
//  Created by Luci Feinberg on 11/13/24.
//

import SwiftUI

struct RecipeListView: View {
    @EnvironmentObject private var viewModel: RecipeViewModel
    @State private var sortOrder: SortOrder = .none
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Loading recipes...")
            } else if let error = viewModel.errorMessage {
                ErrorView(message: error)
            } else {
                VStack {
                    recipeList
                }
            }
        }
        .navigationTitle("Recipes")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: { sortOrder = .none }) {
                        Label("Default", systemImage: sortOrder == .none ? "checkmark" : "")
                    }
                    
                    Button(action: { sortOrder = .highestRated }) {
                        Label("Highest Rated", systemImage: sortOrder == .highestRated ? "checkmark" : "")
                    }
                    
                    Button(action: { sortOrder = .lowestRated }) {
                        Label("Lowest Rated", systemImage: sortOrder == .lowestRated ? "checkmark" : "")
                    }
                } label: {
                    Label("Sort", systemImage: "arrow.up.arrow.down")
                        .foregroundColor(.blue)
                }
            }
        }
    }
    
    private var sortedRecipes: [Recipe] {
        switch sortOrder {
        case .highestRated:
            return viewModel.recipes.sorted { $0.user_ratings.score > $1.user_ratings.score }
        case .lowestRated:
            return viewModel.recipes.sorted { $0.user_ratings.score < $1.user_ratings.score }
        case .none:
            return viewModel.recipes
        }
    }
    
    private var recipeList: some View {
        List(sortedRecipes) { recipe in
            NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                RecipeRowView(recipe: recipe)
            }
        }
    }
}

enum SortOrder {
    case none
    case highestRated
    case lowestRated
}

struct RecipeRowView: View {
    let recipe: Recipe
    @State private var image: UIImage?
    
    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: recipe.thumbnail_url)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.gray
            }
            .frame(width: 80, height: 80)
            .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(recipe.name)
                    .font(.headline)
                    .lineLimit(1)
                Text(recipe.description)
                    .font(.subheadline)
                    .lineLimit(2)
                
                HStack {
                    Label {
                        Text(String(format: "%.1f", recipe.user_ratings.score * 10))
                    } icon: {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                    }
                    
                    Spacer()
                    
                    Label {
                        Text("\(recipe.num_servings)")
                    } icon: {
                        Image(systemName: "person.2")
                            .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    Label {
                        Text("\(recipe.nutrition.calories)")
                    } icon: {
                        Image(systemName: "flame")
                            .foregroundColor(.red)
                    }
                }
                .font(.caption)
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, 8)
    }
}

struct ErrorView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.red)
            Text(message)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

struct RecipeListView_Previews: PreviewProvider {
    static var previews: some View {
        RecipeListView()
            .environmentObject(RecipeViewModel())
    }
}
