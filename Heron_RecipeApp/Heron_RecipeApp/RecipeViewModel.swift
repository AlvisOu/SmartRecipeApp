//
//  RecipeViewModel.swift
//  Heron_RecipeApp
//
//  Created by  dam2274 on 11/25/24.
//

import Foundation

class RecipeViewModel: ObservableObject {
    @Published var recipes: [Recipe] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func fetchRecipes(for ingredients: [String]) {
        isLoading = true
        errorMessage = nil
        
        for ingredient in ingredients {
            guard let url = URL(string: "https://tasty.p.rapidapi.com/recipes/list?from=0&size=20&q=\(ingredient)") else {
                continue
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("tasty.p.rapidapi.com", forHTTPHeaderField: "x-rapidapi-host")
            request.setValue("c8e002e7d3mshc6cd4e104605f58p1671d2jsn8dcbf887c52e", forHTTPHeaderField: "x-rapidapi-key")
            
            URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                DispatchQueue.main.async {
                    if let error = error {
                        self?.errorMessage = error.localizedDescription
                        self?.isLoading = false
                        return
                    }
                    
                    guard let httpResponse = response as? HTTPURLResponse,
                          httpResponse.statusCode == 200 else {
                        self?.errorMessage = "Server error"
                        self?.isLoading = false
                        return
                    }
                    
                    guard let data = data else {
                        self?.errorMessage = "No data received"
                        self?.isLoading = false
                        return
                    }
                    
                    do {
                        let foodItem = try JSONDecoder().decode(FoodItem.self, from: data)
                        self?.recipes.append(contentsOf: foodItem.results)
                    } catch {
                        self?.errorMessage = error.localizedDescription
                    }
                    
                    self?.isLoading = false
                }
            }.resume()
        }
    }
}
