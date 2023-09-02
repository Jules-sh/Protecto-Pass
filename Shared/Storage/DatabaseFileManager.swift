//
//  DatabaseFileManager.swift
//  Protecto Pass
//
//  Created by Julian Schumacher as FileManager.swift on 28.03.23.
//
//  Renamed by Julian Schumacher to DatabaseFileManager.swift on 27.08.23.
//

import Foundation

/// The Struct controlling reading and writing
/// from and to a file, if the user selected that he wants
/// this safe to be stored as a file
internal struct DatabaseFileManager : DatabaseCache {
    
    internal static var allDatabases: [EncryptedDatabase] = []
    
    internal static func accessCache(id: UUID) throws -> EncryptedDatabase {
        if databaseExists(id: id) {
            return allDatabases.first(where: { $0.id == id })!
        } else {
            throw DatabaseDoesNotExistError()
        }
    }
    
    internal static func update(id: UUID, with new: EncryptedDatabase) {
        allDatabases.removeAll(where: { $0.id == id })
        allDatabases.append(new)
    }
    
    internal static func databaseExists(id: UUID) -> Bool {
        return allDatabases.contains(where: { $0.id == id })
    }
    
    internal static func storeDatabase(_ db : EncryptedDatabase) throws -> Void {
        let jsonDB : [String : Any] = db.parseJSON()
        guard let url : URL = db.header.path else {
            throw Error()
        }
        var jsonAsString : String = ""
        for jsonPair in jsonDB {
            jsonAsString.append("\(jsonPair.key): \(jsonPair.value)")
        }
        // TODO: allowLossyConversion?
        let utf8Data : Data = jsonAsString.data(using: .utf8)!
        // TODO: review options
        let base64Data : Data = utf8Data.base64EncodedData()
        try base64Data.write(to: url)
        update(id: db.id, with: db)
    }
    
    internal static func load() -> [EncryptedDatabase] {
        // TODO: implement
        return []
    }
}
