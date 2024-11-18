import Foundation

// MARK: - Models
struct FoodItem: Codable {
    let count: Int
    let results: [Recipe]
}

struct Recipe: Codable, Identifiable {
    let id = UUID()
    let cook_time_minutes: Int
    let description: String
    let instructions: [Instruction]
    let name: String
    let num_servings: Int
    let nutrition: Nutrition
    let prep_time_minutes: Int
    let sections: [Section]
    let thumbnail_url: String
    let total_time_minutes: Int
    let user_ratings: UserRatings
    let video_url: String?
    
    enum CodingKeys: String, CodingKey {
        case cook_time_minutes, description, instructions, name
        case num_servings, nutrition, prep_time_minutes, sections
        case thumbnail_url, total_time_minutes, user_ratings, video_url
    }
    
    static var preview: Recipe {
        let previewData = """
        {
            "cook_time_minutes": 30,
            "description": "A delicious recipe description",
            "instructions": [
                {"id": 1, "display_text": "Step 1", "position": 1},
                {"id": 2, "display_text": "Step 2", "position": 2}
            ],
            "name": "Preview Recipe",
            "num_servings": 4,
            "nutrition": {},
            "prep_time_minutes": 15,
            "sections": [
                {
                    "components": [
                        {"raw_text": "Ingredient 1"},
                        {"raw_text": "Ingredient 2"}
                    ],
                    "name": "Main Ingredients",
                    "position": 1
                }
            ],
            "thumbnail_url": "",
            "total_time_minutes": 45,
            "user_ratings": {
                "count_negative": 0,
                "count_positive": 10,
                "score": 0.9
            },
            "video_url": null
        }
        """.data(using: .utf8)!
        
        return try! JSONDecoder().decode(Recipe.self, from: previewData)
    }
}

struct UserRatings: Codable {
    let countNegative, countPositive: Int
    let score: Double

    enum CodingKeys: String, CodingKey {
        case countNegative = "count_negative"
        case countPositive = "count_positive"
        case score
    }
}

struct Nutrition: Codable {
    let calories: Int
    let carbohydrates: Int
    let fat: Int
    let fiber: Int
    let protein: Int
    let sugar: Int

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        calories = try container.decodeIfPresent(Int.self, forKey: .calories) ?? 0
        carbohydrates = try container.decodeIfPresent(Int.self, forKey: .carbohydrates) ?? 0
        fat = try container.decodeIfPresent(Int.self, forKey: .fat) ?? 0
        fiber = try container.decodeIfPresent(Int.self, forKey: .fiber) ?? 0
        protein = try container.decodeIfPresent(Int.self, forKey: .protein) ?? 0
        sugar = try container.decodeIfPresent(Int.self, forKey: .sugar) ?? 0
    }
}

struct Instruction: Codable, Identifiable {
    let id: Int
    let display_text: String
    let position: Int
}

struct Section: Codable {
    let components: [Component]
    let name: String?
    let position: Int
}

struct Component: Codable {
    let raw_text: String
}
