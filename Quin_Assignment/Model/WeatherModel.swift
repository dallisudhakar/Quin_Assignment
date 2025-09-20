//
//  WeatherModel.swift
//  Quin_Assignment
//
//  Created by apple on 9/20/25.
//

import Foundation

struct Weather: Codable, Equatable {
    let temp: Double
    let feelsLike: Double?
    let description: String
    let timezoneOffsetSeconds: Int?
}
