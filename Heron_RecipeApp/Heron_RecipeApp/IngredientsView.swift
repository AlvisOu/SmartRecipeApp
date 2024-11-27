//
//  IngredientsView.swift
//  Heron_RecipeApp
//
//  Created by Luci Feinberg on 11/13/24.
//

import SwiftUI
import Pluralize

struct IngredientsView: View {
    @State var ingredients: [String]
    @State private var showingAddView = false
    @State private var showingEditView = false
    
    var body: some View {
        
        VStack {
            HStack {
                // MARK: Add Ingredient Button
                Button(action: {
                    showingAddView = true
                }) {
                    Label("Add Ingredient", systemImage: "plus.circle.fill")
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                // MARK: Edit Button
                Button(action: {
                    showingEditView = true
                }) {
                    Text("Edit")
                        .foregroundColor(.blue)
                }
            }
            .padding([.horizontal, .top])
            
            // MARK: Header
            Text("Ingredients")
                .font(.title)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.top,3)
            
            // MARK: List of Ingredients
            List {
                ForEach(ingredients, id: \.self){ ingredient in Text(ingredient)}
            }
        }
        
        // MARK: Generate Recipe Button
        NavigationLink(destination: GenerateRecipeView(ingredients: ingredients)) {
            Text("Generate Recipe")
                .font(.system(size: 20))
                .foregroundColor(.blue)
                .frame(width: 250)
                .padding()
                .background(Color(.systemGray5))
                .cornerRadius(20)
                .padding(.top, 10)
                .padding(.bottom, 1)
            
        }
        
        
        // Navigate to Add Ingredient Sheet
        .sheet(isPresented: $showingAddView) {
            AddNewIngredientView(ingredients: $ingredients)
        }
        
        // Navigate to Edit Screen
        .fullScreenCover(isPresented: $showingEditView) {
            EditIngredientsView(ingredients:$ingredients)
        }
    }
}

//MARK: Add Ingredient Sheet
struct AddNewIngredientView: View {
    @Binding var ingredients: [String]
    @State private var newIngredient: String = ""
    @Environment(\.dismiss) private var dismiss
    @State private var showDuplicateAlert = false
    
    var body: some View {
        VStack {
            Text("Add new ingredient")
                .padding(.top)
                .fontWeight(.semibold)
            
            Form {
                TextField("Enter ingredient", text: $newIngredient)
                
                Button(action: {
                    addIngredient()
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add new item")
                    }
                }
            }
            Text("Swipe down to cancel.")
                .padding(.top)
        }
        .alert(isPresented: $showDuplicateAlert) {
            Alert(
                title: Text("Duplicate Ingredient"),
                message: Text("This ingredient is already in the list."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    private func addIngredient() {
        let normalizedIngredient = newIngredient.singularized.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !normalizedIngredient.isEmpty {
            if !ingredients.contains(where: { $0.lowercased() == normalizedIngredient }) {
                ingredients.append(normalizedIngredient.capitalized)
                dismiss()
            } else {
                showDuplicateAlert = true
            }
        }
    }
}

//MARK: Edit List of Ingredient Screen
    struct EditIngredientsView: View {
        @Binding var ingredients: [String]
        @State private var selectedIngredients = Set<String>()
        @State private var originalIngredients = [String]()
        @Environment(\.dismiss) private var dismiss
        
        var body: some View {
            NavigationStack {
                VStack {
                    List(ingredients, id: \.self, selection: $selectedIngredients) { ingredient in
                        HStack {
                            Text(ingredient)
                        }
                    }
                    .environment(\.editMode, Binding.constant(EditMode.active))
                    
                    // Delete Button
                    .navigationBarItems(
                        leading:
                            Button("Cancel") {
                                ingredients = originalIngredients
                                dismiss()
                            },
                        trailing:
                            Button("Delete") {
                                deleteSelectedIngredients()
                                dismiss()
                            }
                            .foregroundStyle(.red)
                    )
                    .navigationTitle("Delete Ingredients")
                    .onAppear {
                        originalIngredients = ingredients
                    }
                    // Swipe left to return to original screen
                    .gesture(
                        DragGesture().onEnded{ value in
                            if value.translation.width > 100 {
                                dismiss()
                            }
                        }
                    )
                    }
                }
            }
        
        // Function to delete selected ingredients from og list
        private func deleteSelectedIngredients() {
                ingredients.removeAll { selectedIngredients.contains($0)}
    }
}
        
//MARK: Generate Recipe View [placeholder]
struct GenerateRecipeView: View {
    let ingredients: [String]
    @StateObject private var viewModel = RecipeViewModel()
    
    var body: some View {
        RecipeListView()
            .onAppear {
                let ingredientString = ingredients.joined(separator: ",")
                viewModel.fetchRecipes(for: [ingredientString])
            }
            .environmentObject(viewModel)
    }
}

#Preview {
    IngredientsView(ingredients: ["Tomato", "Cucumber", "Carrot"])
        .environmentObject(RecipeViewModel())
}
