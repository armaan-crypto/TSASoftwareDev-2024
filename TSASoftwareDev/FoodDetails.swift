//
//  FoodDetails.swift
//  TSASoftwareDev
//
//  Created by Armaan Ahmed on 4/25/24.
//

import SwiftUI
import SwiftSoup
import AlertToast

struct FoodDetails: View {
    let tags = ["Appetizers","Baking","Breakfast","Dessert","Dinner","Fish","Lunch","Main","Quick","Side","Snack","Spicy","Vegan","Vegetarian"]
    let allergies = ["Peanut", "Milk"]
    @State var ingredients = [FoodIngredient]()
    @Binding var food: Food
    @State var isAllergic = false
    @State var isNotAllergic = false
    
    var body: some View {
        ScrollView {
            VStack {
                Spacer().frame(height: 20)
                Text(food.title)
                    .bold()
                    .font(.system(size: 20))
                    .multilineTextAlignment(.center)
                FlowLayout {
                    ForEach(ingredients, id: \.self) { tag in
                        HStack {
                            Text(tag.name.toStringFromHTML())
                                .fixedSize()
                                .font(.headline)
                        }
                        .padding(10)
                        .background(
                            Capsule()
                                .stroke(tag.isOkay ? .green : .red)
                        )
                        .padding(5)
                    }
                }
                .padding()
                Spacer()
            }
        }
        .onAppear(perform: {
            if food.allergic {
                isAllergic = true
            } else {
                isNotAllergic = true
            }
        })
        .padding()
        .onAppear(perform: { ingredients = food.ingredients })
        .toast(isPresenting: $isAllergic) {
            AlertToast(type: .error(.red), title: "Allergic")
        }
        .toast(isPresenting: $isNotAllergic) {
            AlertToast(type: .complete(.green), title: "OK To Eat")
        }
    }
    
    func isAllergic(ingredient: String) -> Bool {
        for allergy in allergies {
            if ingredient.lowercased().contains(allergy.lowercased()) { return true }
        }
        return false
    }
}

struct FoodIngredient: Identifiable, Hashable {
    var id: UUID { UUID() }
    let name: String
    let isOkay: Bool
}

struct FlowLayout: Layout {
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }

        var totalHeight: CGFloat = 0
        var totalWidth: CGFloat = 0

        var lineWidth: CGFloat = 0
        var lineHeight: CGFloat = 0

        for size in sizes {
            if lineWidth + size.width > proposal.width ?? 0 {
                totalHeight += lineHeight
                lineWidth = size.width
                lineHeight = size.height
            } else {
                lineWidth += size.width
                lineHeight = max(lineHeight, size.height)
            }

            totalWidth = max(totalWidth, lineWidth)
        }

        totalHeight += lineHeight

        return .init(width: totalWidth, height: totalHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }

        var lineX = bounds.minX
        var lineY = bounds.minY
        var lineHeight: CGFloat = 0

        for index in subviews.indices {
            if lineX + sizes[index].width > (proposal.width ?? 0) {
                lineY += lineHeight
                lineHeight = 0
                lineX = bounds.minX
            }

            subviews[index].place(
                at: .init(
                    x: lineX + sizes[index].width / 2,
                    y: lineY + sizes[index].height / 2
                ),
                anchor: .center,
                proposal: ProposedViewSize(sizes[index])
            )

            lineHeight = max(lineHeight, sizes[index].height)
            lineX += sizes[index].width
        }
    }
}

//#Preview {
//    FoodDetails(food: Food(id: 1, title: "Food Name", ingredientList: "Ingredient 1, Peanuts, Ingredient 2"))
//}

extension String {
    func toStringFromHTML() -> String {
        do {
           let doc: Document = try SwiftSoup.parse(self)
           return try doc.text()
        } catch Exception.Error(let type, let message) {
            print(message)
            return self
        } catch {
            print("error")
            return self
        }
    }
}
