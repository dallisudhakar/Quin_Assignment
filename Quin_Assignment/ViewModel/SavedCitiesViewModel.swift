//
//  SavedCitiesViewModel.swift
//  Quin_Assignment
//
//  Created by apple on 9/20/25.
//

import Foundation

@MainActor
final class SavedCitiesViewModel: ObservableObject {
    @Published var savedCities: [City] = []
    @Published var errorMessage: String?
    private let repo = CityRepository()
    
    func load() {
        do {
            savedCities = try repo.fetchSavedCities()
        } catch {
            savedCities = []
            errorMessage = "Failed to load saved cities: \(error.localizedDescription)"
        }
    }
    
    func delete(at offsets: IndexSet) {
        for idx in offsets {
            let city = savedCities[idx]
            do {
                try repo.deleteCity(city)
            } catch {
                errorMessage = "Failed to delete: \(error.localizedDescription)"
            }
        }
        load()
    }
}
