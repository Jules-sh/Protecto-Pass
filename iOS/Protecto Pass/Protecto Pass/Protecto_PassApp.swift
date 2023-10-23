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
    @State private var largeScreen : Bool = false

    /// Whether the compact Mode is activated or not
    @State private var compactMode : Bool = false
    
    internal init() {
        let settings : [Settings : Bool] = SettingsHelper.load()
        compactMode = settings[.compactMode]!
        largeScreen = settings[.largeScreen]!
    }

    var body: some Scene {
        WindowGroup {
            SetUpView()
                .onAppear { SettingsHelper.loadiCloud(with: persistenceController.container.viewContext) }
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environment(\.largeScreen, largeScreen)
                .environment(\.compactMode, compactMode)
        }
    }
}
