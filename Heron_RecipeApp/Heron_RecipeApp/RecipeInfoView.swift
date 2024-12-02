import SwiftUI

// MARK: - Model
struct RecipeInfo: Identifiable {
    let id = UUID()
    let ingredients: [String]
    let cookingTime: Int
    let nutrition: Nutrition
    
    struct Nutrition {
        let calories: Int
        let protein: Int
        let carbs: Int
        let fat: Int
    }
}

// MARK: - Sample Data
let sampleRecipeInfo = RecipeInfo(
    ingredients: [
        "2 cups flour",
        "1/2 cup sugar",
        "1 tsp baking powder",
        "1/2 cup butter",
        "1 large egg",
        "1/4 cup milk",
        "1 tsp vanilla extract"
    ],
    cookingTime: 30,
    nutrition: RecipeInfo.Nutrition(
        calories: 320,
        protein: 4,
        carbs: 45,
        fat: 14
    )
)

// MARK: - RecipeInfoView
struct RecipeInfoView: View {
    var recipe: RecipeInfo
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Title and Cooking Time
                Text("Recipe Details")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)
                
                Text("Cooking Time: \(recipe.cookingTime) minutes")
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                Divider()
                    .padding(.vertical)
                
                // Ingredients Section
                Text("Ingredients")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                ForEach(recipe.ingredients, id: \.self) { ingredient in
                    Text("• \(ingredient)")
                        .font(.body)
                        .padding(.leading, 10)
                        .foregroundColor(.primary)
                }
                
                Divider()
                    .padding(.vertical)
                
                // Nutrition Section
                Text("Nutrition Information")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Calories")
                            .font(.headline)
                        Text("\(recipe.nutrition.calories) kcal")
                            .font(.body)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Protein")
                            .font(.headline)
                        Text("\(recipe.nutrition.protein) g")
                            .font(.body)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Carbs")
                            .font(.headline)
                        Text("\(recipe.nutrition.carbs) g")
                            .font(.body)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Fat")
                            .font(.headline)
                        Text("\(recipe.nutrition.fat) g")
                            .font(.body)
                    }
                }
                .padding(.top, 8)
                
                Spacer()
            }
            .padding()
        }

    }
}

// MARK: - Preview
struct RecipeInfoView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RecipeInfoView(recipe: sampleRecipeInfo)
        }
    }
}
