//
//  HomeView.swift
//  Quin_Assignment
//
//  Created by apple on 9/20/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var vm = HomeViewModel()
    @State private var query: String = ""
    @State private var queryToSearch: String? = nil
    
    var body: some View {
        VStack {
            // Search bar
            HStack {
                TextField("Search city...", text: $query)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("Go") {
                    if !query.isEmpty {
                        vm.addSearch(query)
                        // Navigate to SearchResultsView
                        queryToSearch = query
                        query = ""
                        
                    }
                }
            }
            
            .padding(.horizontal)
            .padding(.top, 20)
            .padding(.bottom, 8)
            NavigationLink(
                destination: SearchResultsView(query: queryToSearch ?? ""),
                tag: queryToSearch ?? "",
                selection: $queryToSearch,
                label: { EmptyView() }
            )
            .hidden()

            // Recent searches
            List {
                ForEach(vm.recentSearches, id: \.self) { item in
                    NavigationLink(destination: SearchResultsView(query: item)) {
                        Text(item)
                            .padding()
                    }
                }
                .onDelete { indexSet in
                    indexSet.map { vm.recentSearches[$0] }.forEach { vm.deleteSearch($0) }
                }
            }
            .padding(.bottom, 8)
        }
    }
}
