//
//  Settings.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 07.09.23.
//

import CoreData
import Foundation
import SwiftUI

/// Enum with a case for every Settings value with the stored identifier
/// String
internal enum Settings : String, RawRepresentable {
    
    case syncPathToiCloud = "sync_paths_preference"
    
    case syncSettingsToiCloud = "sync_settings_preference"
    
    case largeScreen = "large_screen_preference"
    
    case compactMode = "compact_mode_preference"
    
    case appVersion = "app_version_preference"
    
    case buildVersion = "build_version_preference"
    
    case resetApp = "reset_app_preference"
}

/// Struct to manage Settings, load and update them
/// out of this App in the Systems Settings App.
internal struct SettingsHelper {
    
    /// Whether the Settings should be synced to iCloud or not
    private static var iCloudSettings : Bool = true
    
    /// Whether the Paths of the databases should be synced to iCloud or not
    private static var iCloudPaths : Bool = true
    
    private static var largeScreen : Bool = false
    
    private static var compactMode : Bool = false
    
    
    /// Initialized the Settings, creates the Preferences Object in
    /// iCloud if needed
    internal static func initialize(with context : NSManagedObjectContext) -> Void {
        if iCloudPaths {
            if try! context.fetch(AppData.fetchRequest()).first == nil {
                let appData : AppData = AppData(context: context)
            }
        }
        if iCloudSettings {
            if let settingsFromiCloud : Preferences = try! context.fetch(Preferences.fetchRequest()).first {
                update(compactMode: settingsFromiCloud.compactMode, largeScreen: settingsFromiCloud.largeScreen)
            } else {
                let preferences : Preferences = Preferences(context: context)
                preferences.compactMode = compactMode
                preferences.largeScreen = largeScreen
            }
        }
    }
    
    /// Loads all the Data to:
    /// 1. the Settings App
    /// 2. This App (returns a Dictionary of all Settings and their values)
    internal static func load() -> [Settings : Bool] {
        updateVersion()
        return loadData()
    }
    
    /// Load the current Value of the Settings
    private static func loadData() -> [Settings : Bool] {
        if checkReset() {
            largeScreen = false
            compactMode = false
            iCloudSettings = true
            iCloudPaths = true
            reset()
        } else {
            largeScreen = UserDefaults.standard.bool(forKey: Settings.largeScreen.rawValue)
            compactMode = UserDefaults.standard.bool(forKey: Settings.compactMode.rawValue)
            iCloudSettings = UserDefaults.standard.bool(forKey: Settings.syncSettingsToiCloud.rawValue)
            iCloudPaths = UserDefaults.standard.bool(forKey: Settings.syncPathToiCloud.rawValue)
        }
        return [
            .largeScreen : largeScreen,
            .compactMode : compactMode,
            .syncSettingsToiCloud : iCloudSettings,
            .syncPathToiCloud : iCloudPaths
        ]
    }
    
    /// Checks whether the "Reset App" Switch in the System Settings App
    /// has been set to true
    private static func checkReset() -> Bool {
        return UserDefaults.standard.bool(forKey: Settings.resetApp.rawValue)
    }
    
    /// Resets the App
    private static func reset() -> Void {
        Storage.clearAll()
    }
    
    /// Update the Version and Build Number of this App in the Settings
    /// App of the System
    private static func updateVersion() -> Void {
        UserDefaults.standard.set(Bundle.main.infoDictionary!["CFBundleShortVersionString"], forKey: Settings.appVersion.rawValue)
        UserDefaults.standard.set(Bundle.main.infoDictionary!["CFBundleVersion"], forKey: Settings.buildVersion.rawValue)
    }
    
    /// Updates all the Settings with those from iCloud
    private static func update(compactMode : Bool, largeScreen : Bool) -> Void {
        UserDefaults.standard.set(compactMode, forKey: Settings.compactMode.rawValue)
        UserDefaults.standard.setValue(largeScreen, forKey: Settings.largeScreen.rawValue)
    }
}

/// Key for the Large Screen Setting injected into the Environment
private struct LargeScreenSettingsKey : EnvironmentKey {
    static var defaultValue: Bool = false
}

/// Key for the Compact Mode Setting injected into the Environment
private struct CompactModeSettingsKey : EnvironmentKey {
    static var defaultValue: Bool = false
}

/// Defines both, the compact Mode and large Screen variable for the SwiftUI
/// Environment
internal extension EnvironmentValues {
    var compactMode : Bool {
        get { self[CompactModeSettingsKey.self] }
        set { self[CompactModeSettingsKey.self] = newValue }
    }
    
    var largeScreen : Bool {
        get { self[LargeScreenSettingsKey.self] }
        set { self[LargeScreenSettingsKey.self] = newValue }
    }
}
