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
    
    /// Returns the fetch Request used to get the current Database with the provided ID
    private static func getFetchRequest(for id : UUID) -> NSFetchRequest<CD_Database> {
        let fetchRequest : NSFetchRequest = CD_Database.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "uuid == %@", DataConverter.uuidToData(id) as NSData)
        return fetchRequest
    }
    
    internal static func accessCache(id: UUID) throws -> CD_Database {
        guard try databaseExists(id: id) else {
            throw DatabaseDoesNotExistError()
        }
        return try getFetchRequest(for: id).execute().first!
    }
    
    internal static func databaseExists(id : UUID) throws -> Bool {
        return try !getFetchRequest(for: id).execute().isEmpty
    }
    
    /// Loads all Databases from the Core Data System
    internal static func load(with context : NSManagedObjectContext) throws -> [EncryptedDatabase] {
        let databases : [CD_Database] = try context.fetch(CD_Database.fetchRequest())
        let encryptedDatabases : [EncryptedDatabase] = try DB_Converter.fromCD(databases)
        return encryptedDatabases
    }
    
    /// Stores the Database to the Core Data System
    internal static func storeDatabase(_ db : EncryptedDatabase, context : NSManagedObjectContext, newElements : [DatabaseContent<Data>]) throws -> Void {
        let oldDB : CD_Database = try accessCache(id: db.id)
        for toc in oldDB.contents! {
            toc as! CD_ToCItem
        }
        if try databaseExists(id: db.id) {
            try deleteDatabase(db.id, with: context)
        }
        let cdDatabase : CD_Database = DB_Converter.toCD(db, context: context)
        for toc in db.contents {
            // TODO: store every item related to this Database, already done above, why?
        }
        // TODO: call save at the end or after every item? => In the end: no unnessecary IO Operations, every time: maybe less RAM pollution
        try context.save()
    }
    
    internal static func deleteDatabase(_ id : UUID, with context : NSManagedObjectContext) throws -> Void {
        let db : CD_Database = try accessCache(id: id)
        let encrypted = try DB_Converter.fromCD(db)
        for toc in encrypted.contents {
            switch toc.type {
                // TODO: make exhaustive switch
            case .entry:
                break
            default:
                break
            }
        }
        try context.delete(accessCache(id: id))
        // TODO: delete all items related to this Database
    }
    
    internal static func clearAll(context : NSManagedObjectContext) -> Void {
        // TODO: clear
    }
}
