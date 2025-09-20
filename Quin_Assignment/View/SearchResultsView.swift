//
//  SearchResultsView.swift
//  Quin_Assignment
//
//  Created by apple on 9/20/25.
//

import SwiftUI

struct SearchResultsView: View {
    let query: String
    @StateObject private var vm: SearchViewModel
    
    init(query: String) {
        self.query = query
        _vm = StateObject(wrappedValue: SearchViewModel(query: query))
    }
    
    var body: some View {
        VStack {
            if vm.isLoading {
                ProgressView("Searching…")
            } else if let error = vm.errorMessage {
                VStack {
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                    Button("Retry") {
                        vm.search(query: query)
                    }
                }
            } else {
                List(vm.results) { city in
                    NavigationLink(destination: CityDetailView(city: city)) {
                        Text(city.displayName)
                    }
                }
            }
        }
        .navigationTitle("Results for \"\(query)\"")
        .onAppear {
            vm.search(query: query)
        }
    }
}
