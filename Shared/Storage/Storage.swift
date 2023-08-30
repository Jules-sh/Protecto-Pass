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
    
    internal static var allDatabases : [EncryptedDatabase] = []
    
    /// Stores the passed Database to the right Storage.
    /// if you want to store something in Core Data, the connected context has to be provided.
    internal static func storeDatabase(_ db : Database, context : NSManagedObjectContext?) throws -> Void {
        let database : EncryptedDatabase = try db.encrypt()
        switch db.header.storageType {
        case .CoreData:
            assert(context != nil, "To store Core Data Databases, a Context must be provided to the storeDatabase Function")
            try CoreDataManager.storeDatabase(database, context: context!)
        case .File:
            DatabaseFileManager.storeDatabase(database)
        case .Keychain:
            KeychainManager.storeDatabase(database)
            break
        }
    }
    
    /// Loads all the Databases from the different Storage Options
    internal static func load(with context : NSManagedObjectContext) throws -> [EncryptedDatabase] {
        var result : [EncryptedDatabase] = []
        // Core Data
        let coreData : [EncryptedDatabase] = try CoreDataManager.load(with: context)
        result.append(contentsOf: coreData)
        // File System
        let fileSystem : [EncryptedDatabase] = DatabaseFileManager.load()
        result.append(contentsOf: fileSystem)
        // Keychain
        let keychain : [EncryptedDatabase] = KeychainManager.load()
        result.append(contentsOf: keychain)
        allDatabases = result
        return result
    }
}
