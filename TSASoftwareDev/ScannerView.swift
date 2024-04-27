//
//  ScannerView.swift
//  TSASoftwareDev
//
//  Created by Armaan Ahmed on 4/25/24.
//

import SwiftUI
import CodeScanner
import AlertToast

struct ScannerView: View {
    
    @State var showingSheet = false
    @State var foodFound: Food = Food(id: 1, title: "food", ingredientList: "ingredients")
    @State var showSpinner = false
    @State var showError = false
    @State var error = ""
    
    var body: some View {
        ZStack {
            VStack {
                CodeScannerView(codeTypes: [.ean8, .ean13]) { response in
                    showSpinner = true
                    switch response {
                    case .success(let result):
//                        let barcode = result.string.substring(from: result.string.index(result.string.startIndex, offsetBy: 1))
                        print(result.string)
                        getFood(upc: result.string)
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
                .frame(height: 200)
                .cornerRadius(20)
                Spacer()
            }
            
        }
        .padding()
        .navigationTitle("Home")
        .sheet(isPresented: $showingSheet) {
            FoodDetails(food: $foodFound)
        }
        .toast(isPresenting: $showSpinner) {
            AlertToast(type: .loading, title: "", subTitle: "")
        }
        .toast(isPresenting: $showError) {
            AlertToast(type: .error(.red), title: "Error", subTitle: error)
        }

    }
    
    func getFood(upc: String) {
        Task {
            do {
                foodFound = try await FoodData().getFood(from: upc)
                print(foodFound)
                showSpinner = false
                showingSheet = true
            } catch {
                showSpinner = false
                self.error = "Item not found in our server"
                showError = true
            }
        }
    }
}

#Preview {
    ScannerView()
}
