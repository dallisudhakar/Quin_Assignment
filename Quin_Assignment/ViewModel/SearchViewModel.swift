//
//  SearchViewModel.swift
//  Quin_Assignment
//
//  Created by apple on 9/20/25.
//

import Foundation

@MainActor
final class SearchViewModel: ObservableObject {
    @Published var results: [City] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let api = APIService.shared
    
    init(query: String = "") {
        if !query.isEmpty {
            Task { await search(query: query) }
        }
    }
    
    func search(query: String) {
        Task {
            isLoading = true
            errorMessage = nil
            do {
                let cities = try await api.searchCities(query: query)
                results = cities
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}
