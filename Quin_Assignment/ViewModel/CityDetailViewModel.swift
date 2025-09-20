//
//  CityDetailViewModel.swift
//  Quin_Assignment
//
//  Created by apple on 9/20/25.
//

import Foundation

@MainActor
final class CityDetailViewModel: ObservableObject {
    @Published var weather: Weather?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isSaved = false

    let city: City
    private let repository = CityRepository()
    private let api = APIService.shared

    init(city: City) {
        self.city = city
        self.weather = city.weather
        
        // Check if city is already saved in Core Data
        if let savedCities = try? CityRepository().fetchSavedCities(),
           savedCities.contains(where: { $0.lat == city.lat && $0.lon == city.lon }) {
            self.isSaved = true
        } else {
            self.isSaved = false
        }
    }


    // Load weather from API, fallback to cached weather if offline
    func loadWeather() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let w = try await api.fetchWeather(lat: city.lat, lon: city.lon)
            self.weather = w
            try repository.saveCity(city, weather: w) // save updated weather
            
        } catch {
            // offline fallback
            if let cachedCity = try? repository.fetchSavedCities().first(where: { $0.lat == city.lat && $0.lon == city.lon }),
               let cachedWeather = cachedCity.weather {
                self.weather = cachedWeather
            } else {
                errorMessage = (error as? APIService.ServiceError)?.localizedDescription ?? error.localizedDescription
            }
        }
        
        isLoading = false
    }

    // Save city manually
    func saveCity() {
        Task {
            do {
                try repository.saveCity(city, weather: weather)
                isSaved = true
            } catch {
                print("Failed to save city: \(error)")
            }
        }
    }
}
