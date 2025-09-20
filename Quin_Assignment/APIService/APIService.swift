//
//  APIService.swift
//  Quin_Assignment
//
//  Created by apple on 9/20/25.
//

import Foundation
import Combine

final class APIService {
    static let shared = APIService()
    private init() {}
    
    enum ServiceError: Error, LocalizedError {
        case missingAPIKey
        case badURL
        case decodingError
        case other(Error)
        
        var errorDescription: String? {
            switch self {
            case .missingAPIKey: return "Missing API key."
            case .badURL: return "Bad URL."
            case .decodingError: return "Failed to decode response."
            case .other(let e): return e.localizedDescription
            }
        }
    }
    // Replace with your key
    private let apiKey = "8f5f4dca453580a018c947099a0e6a7d"
    
    // Geocoding: returns array of locations matching query
    func searchCities(query: String, limit: Int = 10) async throws -> [City] {
        guard !apiKey.isEmpty else { throw ServiceError.missingAPIKey }
        guard let escaped = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { throw ServiceError.badURL }
        let urlString = "https://api.openweathermap.org/geo/1.0/direct?q=\(escaped)&limit=\(limit)&appid=\(apiKey)"
        guard let url = URL(string: urlString) else { throw ServiceError.badURL }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoder = JSONDecoder()
        do {
            let raw = try decoder.decode([OpenGeocode].self, from: data)
           // print("Raw JSON:", raw)
            return raw.map { City(name: $0.name, state: $0.state, country: $0.country, lat: $0.lat, lon: $0.lon) }
        } catch {
            throw ServiceError.decodingError
        }
    }
    
    // Weather: returns current weather for lat/lon
    func fetchWeather(lat: Double, lon: Double) async throws -> Weather {
        guard !apiKey.isEmpty else { throw ServiceError.missingAPIKey }
        let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&units=metric&appid=\(apiKey)"
        guard let url = URL(string: urlString) else { throw ServiceError.badURL }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoder = JSONDecoder()
        do {
            let raw = try decoder.decode(OpenWeatherResponse.self, from: data)
            let desc = raw.weather.first?.description ?? ""
            return Weather(temp: raw.main.temp, feelsLike: raw.main.feels_like, description: desc, timezoneOffsetSeconds: raw.timezone)
        } catch {
            throw ServiceError.decodingError
        }
    }
}

// MARK: - API response structs
private struct OpenGeocode: Codable {
    let name: String
    let lat: Double
    let lon: Double
    let country: String
    let state: String?
    
    enum CodingKeys: String, CodingKey {
        case name, lat, lon, country, state
    }
}

private struct OpenWeatherResponse: Codable {
    struct Main: Codable { let temp: Double; let feels_like: Double }
    struct WeatherEntry: Codable { let description: String }
    let main: Main
    let weather: [WeatherEntry]
    let timezone: Int?
}
