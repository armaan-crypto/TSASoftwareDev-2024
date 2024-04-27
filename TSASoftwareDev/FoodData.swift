//
//  FoodData.swift
//  TSASoftwareDev
//
//  Created by Armaan Ahmed on 4/24/24.
//

import Foundation

struct FoodData {
    let apiKey = "206ca17b03844dd2ac82f3b8916510e8"
    func getFood(from upc: String) async throws -> Food {
        let url = URL(string: "https://api.spoonacular.com/food/products/upc/\(upc)?apiKey=" + apiKey)!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(Food.self, from: data)
    }
    
    func removeParenthesesBlocks(from str: String) -> String {
      var result = ""
      var openCount = 0
      
      for char in str {
        if char == "(" {
          openCount += 1
        } else if char == ")" {
          openCount -= 1
        } else if openCount == 0 {
          result.append(char)
        }
      }
      return result
    }
}

struct Food: Codable, Identifiable {
    let id: Int
    let title: String
    var ingredientList: String
    
    var allergic: Bool {
        for ingredient in ingredients {
            if !ingredient.isOkay {
                return true
            }
        }
        return false
    }
    
    var ingredients: [FoodIngredient] {
        var ingredients = [FoodIngredient]()
        let ingreds = FoodData().removeParenthesesBlocks(from: ingredientList)
        for ing in ingreds.split(separator: ",") {
            let i = String(ing)
            ingredients.append(FoodIngredient(name: i, isOkay: !isAllergic(ingredient: i)))
        }
        return ingredients
    }
    
    func isAllergic(ingredient: String) -> Bool {
        let allergies = (UserDefaults.standard.value(forKey: "allergies") as? [String]) ?? []
        for allergy in allergies {
            if ingredient.lowercased().contains(allergy.lowercased()) { return true }
        }
        return false
    }
    
    func toJson() throws -> Data? {
        return try JSONEncoder().encode(self)
    }
}
