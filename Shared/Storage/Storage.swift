//
//  Storage.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 30.03.23.
//

import CoreData
import Foundation

/// The Structure to use when storing
/// Databases and other Data. This Struct
/// chooses the right Storage Struct and Functionality
/// depending on the User Preferences on storing
/// Data.
internal struct Storage {
    
    /// The Enum to declare how the Database is stored.
    internal enum StorageType : String, RawRepresentable, CaseIterable, Identifiable {
        var id : Self { self }
        
        /// Storing this Database as an encrypted Core Data Instance
        case CoreData
        
        /// Storing this Database in an local encrypted binary File
        case File
    }
    
    /// Stores the passed Database to the right Storage.
    /// if you want to store something in Core Data, the connected context has to be provided.
    internal static func storeDatabase(_ db : Database, context : NSManagedObjectContext?) throws -> Void {
        let database : EncryptedDatabase = try db.encrypt()
        switch db.header.storageType {
        case .CoreData:
            assert(context != nil, "To store Core Data Databases, a Context must be provided to the storeDatabase Function")
            try CoreDataManager.storeDatabase(database, context: context!)
        case .File:
            try DatabaseFileManager.storeDatabase(database)
        }
    }
    
    /// Loads all the Databases from the different Storage Options
    internal static func load(with context : NSManagedObjectContext, and paths : [URL]) throws -> [EncryptedDatabase] {
        var result : [EncryptedDatabase] = []
        // Core Data
        let coreData : [EncryptedDatabase] = try CoreDataManager.load(with: context)
        result.append(contentsOf: coreData)
        // File System
        let fileSystem : [EncryptedDatabase] = try DatabaseFileManager.load(with: paths)
        result.append(contentsOf: fileSystem)
        result.sort(by: { $0.lastEdited < $1.lastEdited })
        return result
    }

    /// Resets all Data of this App and the connected Cloud Container
    internal static func clearAll() -> Void {
        // TODO: implement
    }
}
