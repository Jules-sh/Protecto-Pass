//
//  Protecto_PassApp.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 01.04.23.
//

import SwiftUI

@main
struct Protecto_PassApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            Home()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
