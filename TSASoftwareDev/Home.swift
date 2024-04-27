//
//  Home.swift
//  TSASoftwareDev
//
//  Created by Armaan Ahmed on 4/26/24.
//

import SwiftUI
import CodeScanner
import AlertToast

struct Home: View {
    
    @State var isPresentingScanner = false
    @State var scannedCode = ""
    @State var justFound = false
    @State var showSpinner = false
    @State var showError = false
    @State var error = ""
    @State var showingSheet = false
    @State var foodFound: Food = Food(id: 1, title: "food", ingredientList: "ingredients")
    @State var isAllergic = false
    @State var isNotAllergic = false
    @State var history = [Food]()
    
    var body: some View {
        VStack {
            if history.count == 0 {
                Text("Scan a food product to get started")
                    .bold()
                    .foregroundStyle(.gray)
            } else {
                List {
                    ForEach(history) { food in
                        HStack {
                            Text(food.title)
                            Spacer()
                            Image(systemName: food.allergic ? "x.circle" : "checkmark.circle")
                                .foregroundStyle(food.allergic ? .red : .green)
                        }
                        .padding()
                    }
                }
            }
        }
        .onAppear(perform: {
            do {
                let en = UserDefaults.standard.value(forKey: "history") as? Data
                history = try JSONDecoder().decode([Food].self, from: en ?? "".data(using: .utf8)!)
            } catch {
                print(error)
            }
        })
        .onChange(of: justFound) { oldValue, newValue in
            if newValue {
                showSpinner = true
                getFood(upc: scannedCode)
                justFound = false
            }
        }
        .navigationTitle("Scanner")
        .toast(isPresenting: $showSpinner) {
            AlertToast(type: .loading)
        }
        .toast(isPresenting: $showError) {
            AlertToast(type: .error(.red), title: "Error", subTitle: error)
        }
//        .toast(isPresenting: $isAllergic) {
//            AlertToast(type: .error(.red), title: "Allergic")
//        }
//        .toast(isPresenting: $isNotAllergic) {
//            AlertToast(type: .complete(.green), title: "OK To Eat")
//        }
        .sheet(isPresented: $showingSheet) {
            FoodDetails(food: $foodFound)
        }
        .sheet(isPresented: $isPresentingScanner) {
            NavigationView {
                VStack {
                    CodeScannerView(codeTypes: [.ean8, .ean13]) { response in
                        if case let .success(result) = response {
                            scannedCode = result.string
                            isPresentingScanner = false
                            justFound = true
                        }
                    }
                    .frame(height: 200)
                    .cornerRadius(20)
                    Spacer()
                }
                .padding()
            }
        }
        .toolbar(content: {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    isPresentingScanner = true
                }, label: {
                    HStack {
                        Text("Scan")
                            .padding(10)
                            .cornerRadius(20)
                            .foregroundStyle(.white)
                            .bold()
                    }
                    .background(.black)
                    .cornerRadius(20)
                })
            }
        })
    }
    
    func getFood(upc: String) {
        Task {
            do {
                foodFound = try await FoodData().getFood(from: upc)
                history.append(foodFound)
                let encodedHistory = try JSONEncoder().encode(history)
                UserDefaults.standard.setValue(encodedHistory, forKey: "history")
                print(foodFound)
                showSpinner = false
                showingSheet = true
//                if foodFound.allergic {
//                    isAllergic = true
//                } else {
//                    isNotAllergic = true
//                }
            } catch {
                showSpinner = false
                self.error = "Item not found in our server"
                showError = true
            }
        }
    }
}

#Preview {
    NavigationView {
        Home()
    }
}
