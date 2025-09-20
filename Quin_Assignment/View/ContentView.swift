//
//  ContentView.swift
//  Quin_Assignment
//
//  Created by apple on 9/20/25.


import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            NavigationView {
                HomeView()
                    .navigationTitle("Weather App")
                   // .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Label("Home", systemImage: "house")
            }

            NavigationView {
                SavedCitiesView()
                    .navigationTitle("Saved Cities")
            }
            .tabItem {
                Label("Saved", systemImage: "star")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}






