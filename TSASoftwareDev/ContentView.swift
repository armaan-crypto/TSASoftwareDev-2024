//
//  ContentView.swift
//  TSASoftwareDev
//
//  Created by Armaan Ahmed on 4/24/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            NavigationView {
                Home()
            }
            .tabItem {
                Label("Home", systemImage: "barcode")
            }
            
            NavigationView {
                Allergies()
            }
            .tabItem {
                Label("Allergies", systemImage: "list.bullet")
            }
        }
    }
}

#Preview {
    ContentView()
}
