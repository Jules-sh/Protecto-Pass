//
//  Storage.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 30.03.23.
//

import Foundation

/// The Structure to use when storing
/// Databases and other Data. This Struct
/// chooses the right Storage Struct and Functionality
/// depending on the User Preferences on storing
/// Data.
internal struct Storage {
    
    internal static func storeDatabase(_ db : EncryptedDatabase) -> Void {
        
    }
    
    internal static func loadDatabase() -> EncryptedDatabase {
        // TODO: change
        return EncryptedDatabase(name: "Test", dbDescription: "Description", header: DB_Header(salt: "Salt"), folders: [])
    }
}
