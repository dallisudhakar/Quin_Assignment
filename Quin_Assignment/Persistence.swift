//
//  Persistence.swift
//  Quin_Assignment
//
//  Created by apple on 9/20/25.
//

import CoreData

import CoreData

final class CityRepository {
    private let container: NSPersistentContainer
    private var viewContext: NSManagedObjectContext { container.viewContext }

    init(container: NSPersistentContainer = PersistenceController.shared.container) {
        self.container = container
    }

    // MARK: - Save city with optional weather info
    func saveCity(_ city: City, weather: Weather? = nil) throws {
        let req = NSFetchRequest<NSManagedObject>(entityName: "SavedCity")
        req.predicate = NSPredicate(format: "lat == %f AND lon == %f", city.lat, city.lon)
        let existing = try viewContext.fetch(req)
        
        let obj: NSManagedObject
        if let first = existing.first {
            obj = first
        } else {
            let ent = NSEntityDescription.entity(forEntityName: "SavedCity", in: viewContext)!
            obj = NSManagedObject(entity: ent, insertInto: viewContext)
            obj.setValue(city.id.uuidString, forKey: "id")
            obj.setValue(city.name, forKey: "name")
            obj.setValue(city.state, forKey: "state")
            obj.setValue(city.country, forKey: "country")
            obj.setValue(city.lat, forKey: "lat")
            obj.setValue(city.lon, forKey: "lon")
            obj.setValue(Date(), forKey: "savedAt")
        }
        
        // Save weather if available
        if let w = weather {
            obj.setValue(w.temp, forKey: "temp")
            obj.setValue(w.feelsLike, forKey: "feelsLike")
            obj.setValue(w.description, forKey: "weatherDescription")
            obj.setValue(w.timezoneOffsetSeconds, forKey: "timezoneOffset")
            obj.setValue(Date(), forKey: "lastUpdated")
        }
        
        try viewContext.save()
    }

    // MARK: - Fetch all saved cities including cached weather
    func fetchSavedCities() throws -> [City] {
        let req = NSFetchRequest<NSManagedObject>(entityName: "SavedCity")
        req.sortDescriptors = [NSSortDescriptor(key: "savedAt", ascending: false)]
        let rows = try viewContext.fetch(req)
        
        return rows.compactMap { row in
            guard let name = row.value(forKey: "name") as? String,
                  let country = row.value(forKey: "country") as? String,
                  let lat = row.value(forKey: "lat") as? Double,
                  let lon = row.value(forKey: "lon") as? Double else { return nil }
            let state = row.value(forKey: "state") as? String
            
            // Create weather object if available
            let temp = row.value(forKey: "temp") as? Double
            let feelsLike = row.value(forKey: "feelsLike") as? Double
            let desc = row.value(forKey: "weatherDescription") as? String
            let tz = row.value(forKey: "timezoneOffset") as? Int
            
            let weather: Weather? = (temp != nil) ? Weather(
                temp: temp!,
                feelsLike: feelsLike,
                description: desc ?? "",
                timezoneOffsetSeconds: tz
            ) : nil
            
            return City(
                name: name,
                state: state,
                country: country,
                lat: lat,
                lon: lon,
                weather: weather
            )
        }
    }

    // MARK: - Delete a city
    func deleteCity(_ city: City) throws {
        let req = NSFetchRequest<NSManagedObject>(entityName: "SavedCity")
        req.predicate = NSPredicate(format: "lat == %f AND lon == %f", city.lat, city.lon)
        let rows = try viewContext.fetch(req)
        for r in rows { viewContext.delete(r) }
        try viewContext.save()
    }
}

// MARK: - Repositories (Persistence Abstraction)
//final class CityRepository {
//    private let container: NSPersistentContainer
//    private var viewContext: NSManagedObjectContext { container.viewContext }
//
//    init(container: NSPersistentContainer = PersistenceController.shared.container) {
//        self.container = container
//    }
//
//    // Save a city into SavedCity entity. Prevent duplicates by lat/lon.
//    func saveCity(_ city: City) throws {
//        let req = NSFetchRequest<NSManagedObject>(entityName: "SavedCity")
//        req.predicate = NSPredicate(format: "lat == %f AND lon == %f", city.lat, city.lon)
//        let existing = try viewContext.fetch(req)
//        if existing.isEmpty {
//            let ent = NSEntityDescription.entity(forEntityName: "SavedCity", in: viewContext)!
//            let obj = NSManagedObject(entity: ent, insertInto: viewContext)
//            obj.setValue(city.id.uuidString, forKey: "id")
//            obj.setValue(city.name, forKey: "name")
//            obj.setValue(city.state, forKey: "state")
//            obj.setValue(city.country, forKey: "country")
//            obj.setValue(city.lat, forKey: "lat")
//            obj.setValue(city.lon, forKey: "lon")
//            obj.setValue(Date(), forKey: "savedAt")
//            try viewContext.save()
//        }
//    }
//
//    func fetchSavedCities() throws -> [City] {
//        let req = NSFetchRequest<NSManagedObject>(entityName: "SavedCity")
//        req.sortDescriptors = [NSSortDescriptor(key: "savedAt", ascending: false)]
//        let rows = try viewContext.fetch(req)
//        return rows.compactMap { row in
//            guard let name = row.value(forKey: "name") as? String,
//                  let country = row.value(forKey: "country") as? String,
//                  let lat = row.value(forKey: "lat") as? Double,
//                  let lon = row.value(forKey: "lon") as? Double else { return nil }
//            let state = row.value(forKey: "state") as? String
//            return City(name: name, state: state, country: country, lat: lat, lon: lon)
//        }
//    }
//
//    func deleteCity(_ city: City) throws {
//        let req = NSFetchRequest<NSManagedObject>(entityName: "SavedCity")
//        req.predicate = NSPredicate(format: "lat == %f AND lon == %f", city.lat, city.lon)
//        let rows = try viewContext.fetch(req)
//        for r in rows { viewContext.delete(r) }
//        try viewContext.save()
//    }
//    
////    func updateWeather(for city: City, weather: Weather) throws {
////        let req = NSFetchRequest<NSManagedObject>(entityName: "SavedCity")
////        req.predicate = NSPredicate(format: "lat == %f AND lon == %f", city.lat, city.lon)
////        if let obj = try viewContext.fetch(req).first {
////            obj.setValue(weather.temp, forKey: "temp")
////            obj.setValue(weather.feelsLike, forKey: "feelsLike")
////            obj.setValue(weather.description, forKey: "descriptionText")
////            obj.setValue(weather.timezoneOffsetSeconds, forKey: "timezoneOffset")
////            obj.setValue(Date(), forKey: "lastUpdated")
////            try viewContext.save()
////        }
////    }
//    func updateWeather(for city: City, weather: Weather) throws {
//        let req = NSFetchRequest<NSManagedObject>(entityName: "SavedCity")
//        req.predicate = NSPredicate(format: "lat == %f AND lon == %f", city.lat, city.lon)
//        if let obj = try viewContext.fetch(req).first {
//            obj.setValue(weather.temp, forKey: "temp")
//            obj.setValue(weather.feelsLike, forKey: "feelsLike")
//            obj.setValue(weather.description, forKey: "weatherDescription")
//            obj.setValue(weather.timezoneOffsetSeconds, forKey: "timezoneOffset")
//            obj.setValue(Date(), forKey: "lastUpdated")
//            try viewContext.save()
//        }
//    }
//
//    
//    func fetchWeather(for city: City) throws -> Weather? {
//        let req = NSFetchRequest<NSManagedObject>(entityName: "SavedCity")
//        req.predicate = NSPredicate(format: "lat == %f AND lon == %f", city.lat, city.lon)
//        guard let obj = try viewContext.fetch(req).first else { return nil }
//        
//        guard let temp = obj.value(forKey: "temp") as? Double else { return nil }
//        let feels = obj.value(forKey: "feelsLike") as? Double
//        let desc = obj.value(forKey: "descriptionText") as? String ?? ""
//        let tz = obj.value(forKey: "timezoneOffset") as? Int
//        
//        return Weather(temp: temp, feelsLike: feels, description: desc, timezoneOffsetSeconds: tz)
//    }
//}


final class SearchHistoryRepository {
    
    private let viewContext: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.viewContext = context
    }
    
    // MARK: - Add a search query (removes duplicates first)
    func addQuery(_ text: String) throws {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        // Remove duplicates (case-insensitive)
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "SearchQuery")
        fetchRequest.predicate = NSPredicate(format: "text ==[c] %@", trimmed)
        
        let results = try viewContext.fetch(fetchRequest)
        for obj in results { viewContext.delete(obj) }
        
        // Insert new query
        let entity = NSEntityDescription.insertNewObject(forEntityName: "SearchQuery", into: viewContext)
        entity.setValue(trimmed, forKey: "text")
        entity.setValue(Date(), forKey: "createdAt")
        
        try viewContext.save()
    }
    
    // MARK: - Fetch recent searches
    func fetchRecent(limit: Int = 10) throws -> [String] {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "SearchQuery")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        fetchRequest.fetchLimit = limit
        
        let results = try viewContext.fetch(fetchRequest)
        return results.compactMap { $0.value(forKey: "text") as? String }
    }
    
    // MARK: - Delete a specific search query
    func deleteQuery(_ text: String) throws {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "SearchQuery")
        fetchRequest.predicate = NSPredicate(format: "text ==[c] %@", text)
        
        let results = try viewContext.fetch(fetchRequest)
        for obj in results { viewContext.delete(obj) }
        
        try viewContext.save()
    }
    
    // MARK: - Delete all search history
    func deleteAll() throws {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "SearchQuery")
        let results = try viewContext.fetch(fetchRequest)
        for obj in results { viewContext.delete(obj) }
        try viewContext.save()
    }
}



// MARK: - Persistence (Programmatic Core Data Model)
final class PersistenceController {
    static let shared = PersistenceController()
    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        let model = Self.makeModel()
        container = NSPersistentContainer(name: "WeatherAppModel", managedObjectModel: model)
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { desc, error in
            if let error = error {
                fatalError("Failed to load Core Data store: \(error)")
            }
            self.container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            self.container.viewContext.automaticallyMergesChangesFromParent = true
        }
    }
    static func makeModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()
        
        // MARK: - SavedCity entity
        let savedCity = NSEntityDescription()
        savedCity.name = "SavedCity"
        savedCity.managedObjectClassName = "NSManagedObject"
        
        var props: [NSAttributeDescription] = []
        
        // Basic city info
        let idAttr = NSAttributeDescription()
        idAttr.name = "id"
        idAttr.attributeType = .stringAttributeType
        idAttr.isOptional = false
        props.append(idAttr)
        
        let nameAttr = NSAttributeDescription()
        nameAttr.name = "name"
        nameAttr.attributeType = .stringAttributeType
        nameAttr.isOptional = false
        props.append(nameAttr)
        
        let stateAttr = NSAttributeDescription()
        stateAttr.name = "state"
        stateAttr.attributeType = .stringAttributeType
        stateAttr.isOptional = true
        props.append(stateAttr)
        
        let countryAttr = NSAttributeDescription()
        countryAttr.name = "country"
        countryAttr.attributeType = .stringAttributeType
        countryAttr.isOptional = false
        props.append(countryAttr)
        
        let latAttr = NSAttributeDescription()
        latAttr.name = "lat"
        latAttr.attributeType = .doubleAttributeType
        latAttr.isOptional = false
        props.append(latAttr)
        
        let lonAttr = NSAttributeDescription()
        lonAttr.name = "lon"
        lonAttr.attributeType = .doubleAttributeType
        lonAttr.isOptional = false
        props.append(lonAttr)
        
        let savedAt = NSAttributeDescription()
        savedAt.name = "savedAt"
        savedAt.attributeType = .dateAttributeType
        savedAt.isOptional = false
        props.append(savedAt)
        
        // ✅ Weather info
        let tempAttr = NSAttributeDescription()
        tempAttr.name = "temp"
        tempAttr.attributeType = .doubleAttributeType
        tempAttr.isOptional = true
        props.append(tempAttr)
        
        let feelsAttr = NSAttributeDescription()
        feelsAttr.name = "feelsLike"
        feelsAttr.attributeType = .doubleAttributeType
        feelsAttr.isOptional = true
        props.append(feelsAttr)
        
        let descAttr = NSAttributeDescription()
        descAttr.name = "weatherDescription"
        descAttr.attributeType = .stringAttributeType
        descAttr.isOptional = true
        props.append(descAttr)
        
        let tzAttr = NSAttributeDescription()
        tzAttr.name = "timezoneOffset"
        tzAttr.attributeType = .integer64AttributeType
        tzAttr.isOptional = true
        props.append(tzAttr)
        
        let lastUpdatedAttr = NSAttributeDescription()
        lastUpdatedAttr.name = "lastUpdated"
        lastUpdatedAttr.attributeType = .dateAttributeType
        lastUpdatedAttr.isOptional = true
        props.append(lastUpdatedAttr)
        
        savedCity.properties = props
        
        // MARK: - SearchQuery entity
        let searchQuery = NSEntityDescription()
        searchQuery.name = "SearchQuery"
        searchQuery.managedObjectClassName = "NSManagedObject"
        
        let qText = NSAttributeDescription()
        qText.name = "text"
        qText.attributeType = .stringAttributeType
        qText.isOptional = false
        
        let qAt = NSAttributeDescription()
        qAt.name = "createdAt"
        qAt.attributeType = .dateAttributeType
        qAt.isOptional = false
        
        searchQuery.properties = [qText, qAt]
        
        // Add entities to model
        model.entities = [savedCity, searchQuery]
        
        return model
    }

    // Convenience helpers
    func saveContext() throws {
        let ctx = container.viewContext
        if ctx.hasChanges { try ctx.save() }
    }
}
