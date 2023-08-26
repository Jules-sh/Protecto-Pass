//
//  CoreDataManager.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 25.08.23.
//

import Foundation
import CoreData

/// Struct used to interact with the Core Data Storage
internal struct CoreDataManager {
    
    internal static func storeDatabase(_ db : EncryptedDatabase, context : NSManagedObjectContext) throws -> Void {
        let _ = DB_Converter.toCD(db, context: context)
        try context.save()
    }
    
    internal static func load(with context : NSManagedObjectContext) throws -> [EncryptedDatabase] {
        let databases : [CD_Database] = try context.fetch(CD_Database.fetchRequest())
        let encryptedDatabases : [EncryptedDatabase] = DB_Converter.fromCD(databases)
        return encryptedDatabases
    }
}
