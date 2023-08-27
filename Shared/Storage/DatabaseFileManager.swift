//
//  DatabaseFileManager.swift
//  Protecto Pass
//
//  Created by Julian Schumacher as FileManager.swift on 28.03.23.
//
//  Renamed by Julian Schumacher to DatabaseFileManager.swift on 27.08.23.
//

import Foundation

/// The Struct controling reading and writing
/// from and to a file, if the user selected that he wants
/// this safe to be stored as a file
internal struct DatabaseFileManager : DatabaseCache, DatabaseManager {
    
    internal static func load() -> [EncryptedDatabase] {
        // TODO: implement
        return []
    }
    
    internal static func storeDatabase(_ db : EncryptedDatabase) -> Void {
        // TODO: implement
    }
    
    static var allDatabases: [Data] = []
    
    static func accessCache(id: UUID) -> Data {
        <#code#>
    }
    
    
    static func update(id: UUID, with new: EncryptedDatabase) {
        <#code#>
    }
    
    static func databaseExists(id: UUID) -> Bool {
        <#code#>
    }
}
