//
//  Protecto_PassApp.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 01.04.23.
//

import SwiftUI

@main
internal struct Protecto_PassApp: App {
    
    /// The Persistence Controller used in this App to store Data
    private let persistenceController : PersistenceController = PersistenceController.shared
    
    
    var body: some Scene {
        WindowGroup {
            SetUpView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
