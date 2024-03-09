//
//  CoreDataManager.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 25.08.23.
//

import Foundation
import CoreData

/// Struct used to interact with the Core Data Storage
internal struct CoreDataManager : DatabaseCache {
    
    internal static var allDatabases: [CD_Database] = []
    
    internal static func accessCache(id: UUID) throws -> CD_Database {
        if databaseExists(id: id) {
            return allDatabases.first(where: { DataConverter.dataToUUID($0.uuid!) == id })!
        } else {
            throw DatabaseDoesNotExistError()
        }
    }
    
    static func databaseExists(id : UUID) -> Bool {
        return allDatabases.contains(where: { DataConverter.dataToUUID($0.uuid!) == id })
    }
    
    static func update(id: UUID, with new: CD_Database) -> Void {
        allDatabases.removeAll(where: { DataConverter.dataToUUID($0.uuid!) == id })
        allDatabases.append(new)
    }
    
    internal static func load(with context : NSManagedObjectContext) throws -> [EncryptedDatabase] {
        let databases : [CD_Database] = try context.fetch(CD_Database.fetchRequest())
        allDatabases = databases
        let encryptedDatabases : [EncryptedDatabase] = try DB_Converter.fromCD(databases)
        return encryptedDatabases
    }
    
    internal static func storeDatabase(_ db : EncryptedDatabase, context : NSManagedObjectContext) throws -> Void {
        if databaseExists(id: db.id) {
            try context.delete(accessCache(id: db.id))
        }
        let cdDatabase : CD_Database = DB_Converter.toCD(db, context: context)
        try context.save()
        update(id: db.id, with: cdDatabase)
    }
}
