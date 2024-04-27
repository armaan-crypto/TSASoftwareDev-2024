//
//  Allergies.swift
//  TSASoftwareDev
//
//  Created by Armaan Ahmed on 4/26/24.
//

import SwiftUI

struct Allergies: View {
    
    @State var showSheet = false
    @State var allergy = ""
    @State var allergies = [String]()
    
    var body: some View {
        VStack {
            if allergies.count == 0 {
                Text("You have no added allergies")
                    .bold()
                    .foregroundStyle(.gray)
            } else {
                List {
                    ForEach(allergies, id: \.self) { a in
                        Text(a)
                            .swipeActions {
                                Button("Remove") {
                                    let _ = withAnimation {
                                        allergies.remove(at: allergies.firstIndex(of: a)!)
                                    }
                                    UserDefaults.standard.setValue(allergies, forKey: "allergies")
                                }
                                .tint(.red)
                            }
                    }
                }
            }
        }
        .onAppear(perform: {
            allergies = (UserDefaults.standard.value(forKey: "allergies") as? [String]) ?? []
        })
        .navigationTitle("My Allergies")
        .sheet(isPresented: $showSheet, content: {
            VStack {
                HStack {
                    TextField("Allergy", text: $allergy)
                        .padding()
                }
                .background(Color(uiColor: .systemGray6))
                .cornerRadius(10)
                Spacer()
                Button(action: {
                    // TODO: add allergy
                    allergies.append(allergy)
                    UserDefaults.standard.setValue(allergies, forKey: "allergies")
                    showSheet = false
                    allergy = ""
                }, label: {
                    HStack {
                        Spacer()
                        Text("Add " + allergy)
                            .padding()
                            .bold()
                            .foregroundStyle(.white)
                        Spacer()
                    }
                    .background(.black)
                })
                .cornerRadius(10)
            }
            .padding()
            .presentationDetents([.medium])
        })
        .toolbar(content: {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {showSheet = true}, label: {
                    HStack {
                        Text("Add Allergy")
                            .bold()
                            .foregroundStyle(.white)
                            .padding(10)
                            .cornerRadius(20)
                    }
                    .background(.black)
                    .cornerRadius(20)
                })
            }
        })
    }
}

#Preview {
    NavigationView {
        Allergies()
    }
}
