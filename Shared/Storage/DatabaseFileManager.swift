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
    
    internal static var paths: [URL] = []
    
    internal static func accessCache(id: UUID) throws -> EncryptedDatabase {
        if databaseExists(id: id) {
            return allDatabases.first(where: { $0.id == id })!
        } else {
            throw DatabaseDoesNotExistError()
        }
    }
    
    internal static func databaseExists(id: UUID) -> Bool {
        return allDatabases.contains(where: { $0.id == id })
    }
    
    internal static func load(from paths : [URL]) throws -> [EncryptedDatabase] {
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
    
    internal static func storeDatabase(_ db : EncryptedDatabase, newElements : [ DatabaseContent<Data>] = []) throws -> Void {
        guard let url : URL = db.header.path else {
            throw NonexistentPathError()
        }
        // TODO: requires secure coding?
        let unarchiver : NSKeyedUnarchiver = try NSKeyedUnarchiver(forReadingFrom: NSData(contentsOf: url)!.decompressed(using: .lzfse) as Data)
        unarchiver.requiresSecureCoding = true
        unarchiver.decodingFailurePolicy = .raiseException
        let archiver : NSKeyedArchiver = NSKeyedArchiver(requiringSecureCoding: true)
        archiver.outputFormat = .binary
        archiver.requiresSecureCoding = true
        try archiver.encodeEncodable(db, forKey: "db")
        
        // Copy file
        
        // Check if element already exists
        for element in newElements {
            //if unarchiver.decodeDecodable(element.self, forKey: element.id.uuidString) != nil {
             //   archiver.encodeEncodable(element, forKey: element.id)
            //}
            // Element does not exist => is new element
            // Add ToC Element to Contents of Database File? Or already done when adding?
        }
        
//        for toc in db.contents {
//            let entity : DatabaseContent<Data>
//            switch toc.type {
//            case .entry:
//                entity = unarchiver.decodeDecodable(EncryptedEntry.self, forKey: toc.id.uuidString)!
//            case .folder:
//                entity = unarchiver.decodeDecodable(EncryptedFolder.self, forKey: toc.id.uuidString)!
//            case .document:
//                entity = unarchiver.decodeDecodable(Encrypted_DB_Document.self, forKey: toc.id.uuidString)!
//            case .image:
//                entity = unarchiver.decodeDecodable(Encrypted_DB_Image.self, forKey: toc.id.uuidString)!
//            default:
//                continue
//            }
//            if let newEntity = newElements.first(where: { $0.id == entity.id }) {
//                entity = newEntity
//            }
//            try archiver.encodeEncodable(entity, forKey: toc.id.uuidString)
//        }
        archiver.finishEncoding()
        try (archiver.encodedData as NSData).compressed(using: .lzfse).write(to: url, options: [.atomic, .completeFileProtection])
    }
    
    // TODO: change to either 'id' or 'path'. Path is better, because it actually represents the location of the database, rather than its id which has to be searched
    internal static func deleteDatabase(_ id : UUID? = nil, at path : URL? = nil) {
        
    }
}
