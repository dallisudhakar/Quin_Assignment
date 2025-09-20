//
//  SavedCitiesView.swift
//  Quin_Assignment
//
//  Created by apple on 9/20/25.
//

import SwiftUI

struct SavedCitiesView: View {
    @StateObject private var vm = SavedCitiesViewModel()
    
    var body: some View {
        VStack {
            if vm.savedCities.isEmpty {
                Text("No saved cities yet").padding()
                Spacer()
            } else {
                List {
                    ForEach(vm.savedCities) { city in
                        NavigationLink(destination: CityDetailView(city: city)) {
                            VStack(alignment: .leading) {
                                Text(city.displayName).font(.headline)
                                Text("Lat: \(city.lat), Lon: \(city.lon)").font(.caption)
                            }
                        }
                    }
                    .onDelete(perform: vm.delete)
                }
            }
        }
        .navigationTitle("Saved Cities")
        .onAppear { vm.load() }
    }
}

