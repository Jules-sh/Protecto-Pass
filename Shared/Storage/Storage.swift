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
    
    internal static func storeDatabase(_ db : EncryptedDatabase) -> Void {
        
    }
    
    internal static func load(with context : NSManagedObjectContext) throws -> [EncryptedDatabase] {
        var result : [EncryptedDatabase] = []
        let coreData : [CD_Database] = try context.fetch(CD_Database.fetchRequest())
        let cdAsEncrypted : [EncryptedDatabase] = DB_Converter.fromCD(coreData)
        result.append(contentsOf: cdAsEncrypted)
        // File System
        // Keychain
        return result
    }
}
