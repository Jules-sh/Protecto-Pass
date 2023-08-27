//
//  KeychainManager.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 25.08.23.
//

import Foundation

internal struct KeychainManager : DatabaseCache, DatabaseManager {
    typealias Database = <#type#>
    
    static func update(id: UUID, with new: EncryptedDatabase) {
        <#code#>
    }
    
    static func databaseExists(id: UUID) -> Bool {
        <#code#>
    }
    
    
    internal static func storeDatabase(_ db : EncryptedDatabase) -> Void {
    }
    
    internal static func load() -> [EncryptedDatabase] {
        // TODO: implement
        return []
    }
}
