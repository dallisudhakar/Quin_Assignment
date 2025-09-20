//
//  CityDetailView.swift
//  Quin_Assignment
//
//  Created by apple on 9/20/25.
//

import SwiftUI
import MapKit

struct CityDetailView: View {
    @StateObject private var vm: CityDetailViewModel
    
    init(city: City) {
        _vm = StateObject(wrappedValue: CityDetailViewModel(city: city))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // City name
                Text(vm.city.displayName)
                    .font(.title)
                    .bold()
                
                // Weather info
                if vm.isLoading {
                    ProgressView("Loading weather…")
                } else if let error = vm.errorMessage {
                    VStack(spacing: 8) {
                        Text("Error: \(error)")
                            .foregroundColor(.red)
                        Button("Retry") {
                            Task { await vm.loadWeather() }
                        }
                    }
                } else if let weather = vm.weather {
                    VStack(spacing: 8) {
                        Text("\(weather.temp)°C")
                            .font(.largeTitle)
                        if let feels = weather.feelsLike {
                            Text("Feels like: \(feels)°C")
                                .font(.subheadline)
                        }
                        Text(weather.description.capitalized)
                            .font(.headline)
                        if let offset = weather.timezoneOffsetSeconds {
                            let tz = TimeZone(secondsFromGMT: offset) ?? .current
                            Text("Timezone: \(tz.identifier)")
                                .font(.subheadline)
                        }
                    }
                }
                
                // Map preview
                Map(coordinateRegion: .constant(
                    MKCoordinateRegion(
                        center: CLLocationCoordinate2D(latitude: vm.city.lat, longitude: vm.city.lon),
                        span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
                    )
                ))
                .frame(height: 250)
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Save button
                Button(action: {
                    vm.saveCity()
                }) {
                    Text(vm.isSaved ? "Saved" : "Save City")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(vm.isSaved ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(vm.isSaved)
                .padding(.horizontal)
            }
            .padding()
        }
        .navigationTitle(vm.city.name)
        .task {
            await vm.loadWeather()
        }
    }
}

