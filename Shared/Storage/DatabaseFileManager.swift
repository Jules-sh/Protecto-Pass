//
//  DatabaseFileManager.swift
//  Protecto Pass
//
//  Created by Julian Schumacher as FileManager.swift on 28.03.23.
//
//  Renamed by Julian Schumacher to DatabaseFileManager.swift on 27.08.23.
//

import Foundation
import CoreData

/// The Struct controlling reading and writing
/// from and to a file, if the user selected that he wants
/// this safe to be stored as a file
internal struct DatabaseFileManager : DatabaseCache {
    
    internal static var allDatabases: [EncryptedDatabase] = []
    
    internal static var currentDatabaseContent : [DatabaseContent<Date, UUID>] = []
    
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
        // TODO: require secure coding is false?
        let archiver : NSKeyedArchiver = NSKeyedArchiver(requiringSecureCoding: true)
        archiver.outputFormat = .binary
        archiver.requiresSecureCoding = true
        // TODO: update and change key
        try archiver.encodeEncodable(db, forKey: "db")
        for obj in currentDatabaseContent {
            let encrypted : EncryptedDataStructure
            // TODO: encrypt data here
            switch obj {
            case is Folder:
                break
            default:
                break
            }
            try archiver.encodeEncodable(encrypted, forKey: obj.id.uuidString)
        }
        archiver.finishEncoding()
        try archiver.encodedData.write(to: url, options: [.atomic, .completeFileProtection])
        update(id: db.id, with: db)
    }
    
    internal static func load(with paths : [URL]) throws -> [EncryptedDatabase] {
        //TODO: Sort for iCloud and not
        var databases : [EncryptedDatabase] = []
        let jsonDecoder : JSONDecoder = JSONDecoder()
        for path in paths {
            let dbData : Data = try Data(contentsOf: path)
            let jsonDB : EncryptedDatabase = try jsonDecoder.decode(EncryptedDatabase.self, from: dbData)
            databases.append(jsonDB)
        }
        return databases
    }
    
    
    /* File specific Implementation */
    
    private static let fm : FileManager = FileManager.default
    
    internal static func loadDatabaseContent(for filePath : URL) throws -> Void {
        
    }
    
    /// Loads the content of the specified Database to the App Documents Directory
    private static func loadDBContentToSandbox(for filePath : URL) throws -> Void {
        let tempDir : URL = fm.temporaryDirectory
        let fileData : Data = try Data(contentsOf: filePath)
        let j = JSONEncoder()
        let unarchiver : NSKeyedUnarchiver = try NSKeyedUnarchiver(forReadingFrom: fileData)
        let encryptedDB : EncryptedDatabase = unarchiver.decodeDecodable(EncryptedDatabase.self, forKey: "db")!
        let db : Database = encryptedDB.decrypt(using: <#T##String#>)
    }
}
