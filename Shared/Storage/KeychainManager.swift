//
//  KeychainManager.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 25.08.23.
//

import Foundation

internal struct KeychainManager : DatabaseCache {
        
    static var allDatabases: [String] = []

    static func accessCache(id: UUID) throws -> String {
        // TODO: implement
        return ""
    }
    
    static func update(id: UUID, with new: String) {
        // TODO: implement
    }
    
    static func databaseExists(id: UUID) -> Bool {
        // TODO: implement
        return true
    }
    
    
    internal static func storeDatabase(_ db : EncryptedDatabase) -> Void {
    }
    
    internal static func load() -> [EncryptedDatabase] {
        // TODO: implement
        return []
    }
}
