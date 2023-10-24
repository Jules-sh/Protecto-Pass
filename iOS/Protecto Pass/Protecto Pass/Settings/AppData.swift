//
//  AppData.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 24.10.23.
//

import CoreData
import Foundation

internal enum AppDataKeys : String, RawRepresentable {
    case paths = "app_data_keys"
}

internal struct AppDataHelper {
    
    internal private(set) static var paths : [URL] = []
    
    internal static func appendPath(_ path : URL) -> Void { paths.append(path) }
    
    internal static func load() -> Void {
        let pathsAsString : [String] = UserDefaults.standard.stringArray(forKey: AppDataKeys.paths.rawValue)!
        for path in pathsAsString {
            paths.append(URL(string: path)!)
        }
    }
    
    internal static func loadiCloud(with context : NSManagedObjectContext) throws -> Void {
        try context.fetch(AppData.fetchRequest())
    }
}
