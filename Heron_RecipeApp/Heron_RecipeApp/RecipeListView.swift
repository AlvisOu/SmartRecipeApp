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
    @State private var servingsFilter: ServingsFilter = .all
    @State private var caloriesFilter: CaloriesFilter = .all
    @State private var timeFilter: CookingTimeFilter = .all
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Loading recipes...")
            } else if let error = viewModel.errorMessage {
                ErrorView(message: error)
            } else {
                recipeContent
            }
        }
        .navigationTitle("Recipes")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    filterMenu
                    sortMenu
                }
            }
        }
    }
    
    private var recipeContent: some View {
        Group {
            if filteredAndSortedRecipes.isEmpty {
                noRecipesView
            } else {
                VStack {
                    recipeList
                }
            }
        }
    }
    
    private var noRecipesView: some View {
        VStack(spacing: 16) {
            Image(systemName: "fork.knife.circle")
                .font(.system(size: 64))
                .foregroundColor(.gray)
            Text("No recipes available")
                .font(.title2)
                .foregroundColor(.secondary)
            Text("Try adjusting your filters or add more ingredients")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
    }
    
    private var filterMenu: some View {
        Menu {
            // Time filter
            Menu("Cooking Time") {
                ForEach(CookingTimeFilter.allCases, id: \.self) { filter in
                    Button(action: { timeFilter = filter }) {
                        Label(filter.description, systemImage: timeFilter == filter ? "checkmark" : "")
                    }
                }
            }
            
            // Servings filter
            Menu("Servings") {
                ForEach(ServingsFilter.allCases, id: \.self) { filter in
                    Button(action: { servingsFilter = filter }) {
                        Label(filter.description, systemImage: servingsFilter == filter ? "checkmark" : "")
                    }
                }
            }
            
            // Calories filter
            Menu("Calories") {
                ForEach(CaloriesFilter.allCases, id: \.self) { filter in
                    Button(action: { caloriesFilter = filter }) {
                        Label(filter.description, systemImage: caloriesFilter == filter ? "checkmark" : "")
                    }
                }
            }
        } label: {
            Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                .foregroundColor(.blue)
        }
    }
    
    private var sortMenu: some View {
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
    
    private var filteredAndSortedRecipes: [Recipe] {
        let filtered = viewModel.recipes.filter { recipe in
            let matchesServings = servingsFilter.matches(servings: recipe.num_servings)
            let matchesCalories = caloriesFilter.matches(calories: recipe.nutrition.calories)
            let matchesTime = timeFilter.matches(totalTime: recipe.total_time_minutes)
            return matchesServings && matchesCalories && matchesTime
        }
        
        switch sortOrder {
        case .highestRated:
            return filtered.sorted { $0.user_ratings.score > $1.user_ratings.score }
        case .lowestRated:
            return filtered.sorted { $0.user_ratings.score < $1.user_ratings.score }
        case .none:
            return filtered
        }
    }
    
    private var recipeList: some View {
        List(filteredAndSortedRecipes) { recipe in
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

enum CookingTimeFilter: CaseIterable {
    case all
    case quick       // Under 30 minutes
    case medium      // 30-60 minutes
    case long       // 60-120 minutes
    case extended   // Over 120 minutes
    
    var description: String {
        switch self {
        case .all: return "All"
        case .quick: return "Under 30 min"
        case .medium: return "30-60 min"
        case .long: return "1-2 hours"
        case .extended: return "Over 2 hours"
        }
    }
    
    func matches(totalTime: Int) -> Bool {
        switch self {
        case .all: return true
        case .quick: return totalTime < 30
        case .medium: return totalTime >= 30 && totalTime < 60
        case .long: return totalTime >= 60 && totalTime < 120
        case .extended: return totalTime >= 120
        }
    }
}

enum ServingsFilter: CaseIterable {
    case all
    case small      // 1-2 servings
    case medium     // 3-4 servings
    case large      // 5-6 servings
    case extraLarge // 7+ servings
    
    var description: String {
        switch self {
        case .all: return "All"
        case .small: return "1-2 servings"
        case .medium: return "3-4 servings"
        case .large: return "5-6 servings"
        case .extraLarge: return "7+ servings"
        }
    }
    
    func matches(servings: Int) -> Bool {
        switch self {
        case .all: return true
        case .small: return servings <= 2
        case .medium: return servings >= 3 && servings <= 4
        case .large: return servings >= 5 && servings <= 6
        case .extraLarge: return servings >= 7
        }
    }
}

enum CaloriesFilter: CaseIterable {
    case all
    case under300
    case under500
    case under800
    case over800
    
    var description: String {
        switch self {
        case .all: return "All"
        case .under300: return "Under 300"
        case .under500: return "Under 500"
        case .under800: return "Under 800"
        case .over800: return "Over 800"
        }
    }
    
    func matches(calories: Int) -> Bool {
        switch self {
        case .all: return true
        case .under300: return calories < 300
        case .under500: return calories < 500
        case .under800: return calories < 800
        case .over800: return calories >= 800
        }
    }
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
