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
        guard let url : URL = db.header.path else {
            throw NonexistentPathError()
        }
        let jsonEncoder : JSONEncoder = JSONEncoder()
        let jsonData : Data = try jsonEncoder.encode(db)
        try jsonData.write(to: url, options: [.atomic, .completeFileProtection])
        update(id: db.id, with: db)
    }
    
    internal static func load() throws -> [EncryptedDatabase] {
        // TODO: get path from somewhere
//        let path : URL = URL(string: "/")!
        var paths : [URL] = []
//        paths.append(path)
        
        var databases : [EncryptedDatabase] = []
        let jsonDecoder : JSONDecoder = JSONDecoder()
        for path in paths {
            let dbData : Data = try Data(contentsOf: path)
            let jsonDB : EncryptedDatabase = try jsonDecoder.decode(EncryptedDatabase.self, from: dbData)
            databases.append(jsonDB)
        }
        return databases
    }
}
