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

    /// Indicates whether the "Large Screen" Setting is true or false
    private let largeScreen : Bool

    /// Whether the compact Mode is activated or not
    private let compactMode : Bool

    internal init() {
        let settings : [Settings : Bool] = SettingsHelper.load()
        largeScreen = settings[.largeScreen]!
        compactMode = settings[.compactMode]!
    }

    var body: some Scene {
        WindowGroup {
            SetUpView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environment(\.largeScreen, largeScreen)
                .environment(\.compactMode, compactMode)
        }
    }
}
