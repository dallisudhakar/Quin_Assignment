//
//  Quin_AssignmentApp.swift
//  Quin_Assignment
//
//  Created by apple on 9/20/25.
//

import SwiftUI

@main
struct Quin_AssignmentApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
