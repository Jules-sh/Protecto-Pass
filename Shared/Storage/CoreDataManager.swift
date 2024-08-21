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
    
    /// Returns the fetch Request used to get the current Database with the provided ID
    private static func getFetchRequest(forDatabaseID id : UUID) -> NSFetchRequest<CD_Database> {
        let fetchRequest : NSFetchRequest = CD_Database.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "uuid == %@", id as NSUUID)
        return fetchRequest
    }
    
    /// Returns the fetch Request used to get the current Image with the provided ID
    private static func getFetchRequest(forImageID id : UUID) -> NSFetchRequest<CD_Image> {
        let fetchRequest : NSFetchRequest = CD_Image.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "uuid == %@", id as NSUUID)
        return fetchRequest
    }
    
    /// Returns the fetch Request used to get the current Video with the provided ID
    private static func getFetchRequest(forVideoID id : UUID) -> NSFetchRequest<CD_Video> {
        let fetchRequest : NSFetchRequest = CD_Video.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "uuid == %@", id as NSUUID)
        return fetchRequest
    }
    
    /// Returns the fetch Request used to get the current Document with the provided ID
    private static func getFetchRequest(forDocumentID id : UUID) -> NSFetchRequest<CD_Document> {
        let fetchRequest : NSFetchRequest = CD_Document.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "uuid == %@", id as NSUUID)
        return fetchRequest
    }
    
    internal static func accessCache(id: UUID, context : NSManagedObjectContext) throws -> CD_Database {
        guard try databaseExists(id: id, context: context) else {
            throw DatabaseDoesNotExistError()
        }
        return try context.fetch(getFetchRequest(forDatabaseID: id)).first!
    }
    
    internal static func databaseExists(id : UUID, context : NSManagedObjectContext) throws -> Bool {
        return try !context.fetch(getFetchRequest(forDatabaseID: id)).isEmpty
    }
    
    /// Loads all Databases from the Core Data System
    internal static func load(with context : NSManagedObjectContext) throws -> [EncryptedDatabase] {
        let databases : [CD_Database] = try context.fetch(CD_Database.fetchRequest())
        let encryptedDatabases : [EncryptedDatabase] = try DB_Converter.fromCD(databases)
        return encryptedDatabases
    }
    
    /// Stores the Database to the Core Data System
    internal static func storeDatabase(_ db : EncryptedDatabase, context : NSManagedObjectContext) throws -> Void {
        if try databaseExists(id: db.id, context: context) {
            try deleteDatabase(db.id, with: context)
        }
        // Store Database including folders and entries, loadable Resource references are stored in this too, the actual resources are stored on adding them to the Database
        let _ = DB_Converter.toCD(db, context: context)
        try context.save()
    }
    
    internal static func storeImage(_ image : Encrypted_DB_Image, context : NSManagedObjectContext) throws -> Void {
        let _ = ImageConverter.toCD(image, context: context)
        try context.save()
    }
    
    internal static func storeVideo(_ video : Encrypted_DB_Video, context : NSManagedObjectContext) throws -> Void {
        let _ = VideoConterter.toCD(video, context: context)
        try context.save()
    }
    
    internal static func storeDocument(_ document : Encrypted_DB_Document, context : NSManagedObjectContext) throws -> Void {
        let _ = DocumentConverter.toCD(document, context: context)
        try context.save()
    }
    
    internal static func deleteDatabase(_ id : UUID, with context : NSManagedObjectContext) throws -> Void {
        let db : CD_Database = try accessCache(id: id, context: context)
        let encrypted = try DB_Converter.fromCD(db)
        context.delete(try accessCache(id: id, context: context))
        for image in encrypted.images {
            let cdImage = try getFetchRequest(forImageID: image.id).execute().first!
            context.delete(cdImage)
        }
        for video in encrypted.videos {
            let cdVideo = try getFetchRequest(forVideoID: video.id).execute().first!
            context.delete(cdVideo)
        }
        for document in encrypted.documents {
            let cdDocument = try getFetchRequest(forDocumentID: document.id).execute().first!
            context.delete(cdDocument)
        }
        try context.save()
    }
    
    internal static func clearAll(context : NSManagedObjectContext) throws -> Void {
        let allDatabases : [EncryptedDatabase] = try load(with: context)
        for db in allDatabases {
            try deleteDatabase(db.id, with: context)
        }
    }
}
