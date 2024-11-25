//
//  Recipe.swift
//  Heron_RecipeApp
//
//  Created by  dam2274 on 11/17/24.
//


//
//  ContentView.swift
//  recipeDisplay
//
//  Created by  dam2274 on 11/11/24.
//

/*

import SwiftUI
import WebKit

// MARK: - Model
struct Recipe: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let image: URL
    let videoID: String
}

// MARK: - Sample Data
let sampleRecipe = Recipe(
    title: "Chicken Soup",
    description: "Chicken soup is a comforting dish made by simmering chicken, vegetables, and seasonings in a flavorful broth. Base typically includes water or stock, creating a warm, nourishing liquid.",
    image: URL(string: "https://bitesinthewild.com/wp-content/uploads/2024/04/Spanish-chicken-soup-recipe-on-pot-with-parsley-on-top.jpg")!,
    videoID: "70DgZgNtV44" // Replace with an actual YouTube video ID
)

// MARK: - YouTubePlayerView
struct YouTubePlayerView: UIViewRepresentable {
    let videoID: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        let url = URL(string: "https://www.youtube.com/embed/\(videoID)")!
        let request = URLRequest(url: url)
        webView.load(request)
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

// MARK: - ContentView
struct ContentView: View {
    let Recipe = sampleRecipe
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Text(Recipe.title)
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.bottom, 5)
                    // NavigationLink wrapping the Button
                    NavigationLink(destination: RecipeInfoView(recipe: sampleRecipeInfo)) {
                        Text("Recipe Details")
                            .font(.title3)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.horizontal, 12)
                    }
                }
                Spacer()
                AsyncImage(url: Recipe.image) { image in
                                    image.resizable()
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(height: 200)
                                .cornerRadius(10)
                Spacer()
                Text(Recipe.description)
                    .font(.body)
                    .padding(.bottom, 10)
                YouTubePlayerView(videoID: Recipe.videoID)
                    .frame(height: 200)
                    .cornerRadius(10)
                    .padding(.vertical)
            }
            .navigationTitle("Recipe Overview")
            .padding()
        }
    }
}

// MARK: - Preview
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

#Preview {
    ContentView()
}
*/

// Testing the dictionary load

import SwiftUI

// Define a dictionary type for storing ingredients and their IDs
typealias IngredientDictionary = [String: Int]

struct ContentView: View {
    @State private var ingredients: [String: Int] = [:]

    var body: some View {
        VStack {
            // Display the ingredient dictionary
            List(ingredients.keys.sorted(), id: \.self) { key in
                if let count = ingredients[key] {
                    Text("\(key): \(count)")
                }
            }
        }
        .onAppear {
            // Load ingredients when the view appears
            loadIngredientsFromCSV()
            self.ingredients = ingredientDictionary
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

