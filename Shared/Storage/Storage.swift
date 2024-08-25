//
//  Storage.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 30.03.23.
//

import CoreData
import Foundation

/// The Structure to use when storing
/// Databases and other Data. This Struct
/// chooses the right Storage Struct and Functionality
/// depending on the User Preferences on storing
/// Data.
internal struct Storage {
    
    /// The Enum to declare how the Database is stored.
    internal enum StorageType : String, RawRepresentable, CaseIterable, Identifiable {
        var id : Self { self }
        
        /// Storing this Database as an encrypted Core Data Instance
        case CoreData
        
        /// Storing this Database in an local encrypted binary File
        case File
    }
    
    /// Loads all the Databases from the different Storage Options
    internal static func load(with context : NSManagedObjectContext, and paths : [URL]) throws -> [EncryptedDatabase] {
        var result : [EncryptedDatabase] = []
        // Core Data
        let coreData : [EncryptedDatabase] = try CoreDataManager.load(with: context)
        result.append(contentsOf: coreData)
        // File System
//        let fileSystem : [EncryptedDatabase] = try DatabaseFileManager.load(from: paths)
//        result.append(contentsOf: fileSystem)
        result.sort(by: { $0.lastEdited < $1.lastEdited })
        return result
    }
    
    internal static func loadImages(_ db : Database, ids: [UUID], context : NSManagedObjectContext?) throws -> [DB_Image] {
        switch db.header.storageType {
            case .CoreData:
                assert(context != nil, "To load Core Data Images, a Context must be provided to the loadImages Function")
                return try CoreDataManager.loadImages(db, ids: ids, with: context!)
            case .File:
                return []
        }
    }
    
    internal static func loadVideos(_ db : Database, ids: [UUID], context : NSManagedObjectContext?) throws -> [DB_Video] {
        switch db.header.storageType {
            case .CoreData:
                assert(context != nil, "To load Core Data Images, a Context must be provided to the loadVideos Function")
                return try CoreDataManager.loadVideos(db, ids: ids, with: context!)
            case .File:
                return []
        }
    }
    
    internal static func loadDocuments(_ db : Database, ids: [UUID], context : NSManagedObjectContext?) throws -> [DB_Document] {
        switch db.header.storageType {
            case .CoreData:
                assert(context != nil, "To load Core Data Images, a Context must be provided to the loadDocuments Function")
                return try CoreDataManager.loadDocuments(db, ids: ids, with: context!)
            case .File:
                return []
        }
    }
    
    /// Stores the passed Database to the right Storage.
    /// if you want to store something in Core Data, the connected context has to be provided.
    internal static func storeDatabase(_ db : Database, context : NSManagedObjectContext?, newElements : [DatabaseContent<Date>] = []) throws -> Void {
        var localDocuments : [Encrypted_DB_Document] = []
        var localImages : [Encrypted_DB_Image] = []
        var localVideos : [Encrypted_DB_Video] = []
        let encrypter : Encrypter = Encrypter.configure(for: db)
        for element in newElements {
            switch element {
                case is Entry:
                    db.entries.append(element as! Entry)
                case is Folder:
                    db.folders.append(element as! Folder)
                case is DB_Document:
                    let doc = element as! DB_Document
                    localDocuments.append(try encrypter.encryptDocument(doc))
                    db.documents.append(LoadableResource(id: doc.id, name: doc.name, thumbnailData: DataConverter.stringToData("doc")))
                case is DB_Image:
                    let im = element as! DB_Image
                    localImages.append(try encrypter.encryptImage(im))
                    db.images.append(LoadableResource(id: im.id, thumbnailData: im.image.jpegData(compressionQuality: 0.1)!))
                case is DB_Video:
                    let vid = element as! DB_Video
                    localVideos.append(try encrypter.encryptVideo(vid))
                    // TODO: add thumbnail data
                    db.videos.append(LoadableResource(id: vid.id, thumbnailData: Data()))
                default:
                    continue
            }
        }
        let database : EncryptedDatabase = try encrypter.encrypt()
        for image in localImages {
            try storeImage(image, in: database, context: context)
        }
        for document in localDocuments {
            try storeDocument(document, in: database, context: context)
        }
        for video in localVideos {
            try storeVideo(video, in: database, context: context)
        }
        switch db.header.storageType {
            case .CoreData:
                assert(context != nil, "To store Core Data Databases, a Context must be provided to the storeDatabase Function")
                try CoreDataManager.storeDatabase(
                    database,
                    context: context!
                )
            case .File:
                break
//                try DatabaseFileManager.storeDatabase(database)
        }
    }
    
    /// Stores a document depending on the storage type
    private static func storeDocument(_ document : Encrypted_DB_Document, in db : EncryptedDatabase, context: NSManagedObjectContext?) throws -> Void {
        switch db.header.storageType {
            case .CoreData:
                assert(context != nil, "To store Core Data Document, a Context must be provided to the storeDocument Function")
                try CoreDataManager.storeDocument(document, context: context!)
            case .File:
                break
//                try DatabaseFileManager.storeDocument(document, in: db)
        }
    }
    
    /// Stores an image depending on the storage type
    private static func storeImage(_ image : Encrypted_DB_Image, in db : EncryptedDatabase, context: NSManagedObjectContext?) throws -> Void {
        switch db.header.storageType {
            case .CoreData:
                assert(context != nil, "To store Core Data Image, a Context must be provided to the storeImage Function")
                try CoreDataManager.storeImage(image, context: context!)
            case .File:
                break
//                try DatabaseFileManager.storeImage(image, in: db)
        }
    }
    
    /// Stores a video depending on the storage type
    private static func storeVideo(_ video : Encrypted_DB_Video, in db : EncryptedDatabase, context: NSManagedObjectContext?) throws -> Void {
        switch db.header.storageType {
            case .CoreData:
                assert(context != nil, "To store Core Data Video, a Context must be provided to the storeVideo Function")
                try CoreDataManager.storeVideo(video, context: context!)
            case .File:
                break
//                try DatabaseFileManager.storeVideo(video, in: db)
        }
    }
    
    /// Stores the currently opened and used Database
    internal static func storeCurrentDatabase() -> Void {
    }
    
    /// Resets all Data of this App and the connected Cloud Container
    internal static func clearAll() -> Void {
        // TODO: implement
    }
}
