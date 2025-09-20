//
//  HomeViewModel.swift
//  Quin_Assignment
//
//  Created by apple on 9/20/25.
//

import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var recentSearches: [String] = []
    
    private let repo = SearchHistoryRepository()
    
    init() {
        loadRecent()
    }
    
    func loadRecent() {
        do {
            recentSearches = try repo.fetchRecent()
        } catch {
            print("Failed to fetch recent searches:", error)
        }
    }
    
    func addSearch(_ text: String) {
        do {
            try repo.addQuery(text)
            loadRecent() // reload immediately
        } catch {
            print("Failed to add search:", error)
        }
    }
    
    func deleteSearch(_ text: String) {
        do {
            try repo.deleteQuery(text)
            loadRecent()
        } catch {
            print("Failed to delete search:", error)
        }
    }
}
