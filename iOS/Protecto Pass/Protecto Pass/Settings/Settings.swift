//
//  Settings.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 07.09.23.
//

import Foundation
import SwiftUI

/// Enum with a case for every Settings value with the stored identifier
/// String
internal enum Settings : String, RawRepresentable {

    case largeScreen = "large_screen_preference"

    case compactMode = "compact_mode_preference"

    case appVersion = "app_version_preference"

    case buildVersion = "build_version_preference"
}

/// Struct to manage Settings, load and update them
/// out of this App in the Systems Settings App.
internal struct SettingsHelper {

    /// Load the current Value of the Settings
    internal static func load() -> [Settings : Bool] {
        let largeScreen : Bool = UserDefaults.standard.bool(forKey: Settings.largeScreen.rawValue)
        let compactMode : Bool = UserDefaults.standard.bool(forKey: Settings.compactMode.rawValue)
        return [
            .largeScreen : largeScreen,
            .compactMode : compactMode
        ]
    }

    /// Update the Settings Values in the Settings App, if necessary
    internal static func update() -> Void {
        UserDefaults.standard.set(Bundle.main.infoDictionary!["CFBundleShortVersionString"], forKey: Settings.appVersion.rawValue)
        UserDefaults.standard.set(Bundle.main.infoDictionary!["CFBundleVersion"], forKey: Settings.buildVersion.rawValue)
    }
}

/// Key for the Large Screen Setting injected into the Environment
private struct LargeScreenSettingsKey : EnvironmentKey {
    static var defaultValue: Bool = false
}

/// Key for the Compact Mode Setting injected into the Environment
private struct CompactModeSettingsKey : EnvironmentKey {
    static var defaultValue: Bool = true
}

/// Defines both, the compact Mode and large Screen variable for the SwiftUI
/// Environment
extension EnvironmentValues {
    var compactMode : Bool {
        get { self[CompactModeSettingsKey.self] }
        set { self[CompactModeSettingsKey.self] = newValue }
    }

    var largeScreen : Bool {
        get { self[LargeScreenSettingsKey.self] }
        set { self[LargeScreenSettingsKey.self] = newValue }
    }
}
