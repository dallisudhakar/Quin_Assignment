//
//  CityModel.swift
//  Quin_Assignment
//
//  Created by apple on 9/20/25.
//

import Foundation

struct City: Identifiable, Codable, Equatable {
    let id = UUID()
    let name: String
    let state: String?
    let country: String
    let lat: Double
    let lon: Double
    var weather: Weather?

    var displayName: String { [name, state, country].compactMap { $0 }.joined(separator: ", ") }
}

