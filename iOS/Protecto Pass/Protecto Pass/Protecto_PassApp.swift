//
//  Protecto_PassApp.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 28.03.23.
//

import SwiftUI

/// The Main Struct representing the App
@main
internal struct Protecto_PassApp: App {
    
    /// The Unlock Helper to help with the unlocking Process of a Database
    @StateObject internal var unlockHelper : UnlockHelper = UnlockHelper()
    
    /// The Persistence Controller to interact with the Core Data Manager and perfom fetch Request
    private let persistenceController : PersistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
        // Idea from: https://www.reddit.com/r/SwiftUI/comments/nmons4/changing_the_app_root_view_with_animation/
            if unlockHelper.unlockState == .unlocked {
                // Show Home if a Database is unlocked
                Home(db: unlockHelper.unlockedDatabase)
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .environmentObject(unlockHelper)
            } else {
                // Show Welcome View if no Database is unlocked
                WelcomeView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .environmentObject(unlockHelper)
            }
        }
    }
}
