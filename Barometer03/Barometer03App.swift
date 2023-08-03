//
//  Barometer03App.swift
//  Barometer03
//
//  Created by Chang Zhou on 2023-06-28.
//

import SwiftUI

@main
struct Barometer03App: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
