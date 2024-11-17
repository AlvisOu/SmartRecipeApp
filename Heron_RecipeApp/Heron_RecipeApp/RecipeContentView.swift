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
            VStack(alignment: .leading, spacing: 20) {
                Text(Recipe.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.bottom, 5)
                
                AsyncImage(url: Recipe.image) { image in
                    image.resizable()
                         .scaledToFill()
                } placeholder: {
                    ProgressView()
                }
                .frame(height: 200)
                .cornerRadius(10)
                
                Text(Recipe.description)
                    .font(.body)
                    .padding(.bottom, 10)
                
                YouTubePlayerView(videoID: Recipe.videoID)
                    .frame(height: 200)
                    .cornerRadius(10)
                    .padding(.vertical)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Recipe Overview")
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
