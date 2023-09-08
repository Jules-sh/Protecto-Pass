//
//  DB_Converter.swift
//  Protecto Pass
//
//  Created by Julian Schumacher as CD_Mapping.swift on 27.05.23.
//
//  Renamed by Julian Schumacher to DB_Converter.swift on 27.05.23.
//

import CoreData
import Foundation

/// Protocol all converters in this File must conform to
private protocol DatabaseConverterProtocol {
    
    /// The Core Data type of the converter
    associatedtype CoreData : NSManagedObject
    
    /// The encrypted Type of the converter
    associatedtype Encrypted
    
    /// Converts the specified Core Data Object to an encrypted Object
    static func fromCD(_ coreData : CoreData) throws -> Encrypted
    
    /// Converts the specified encrypted Object to a core Data Object
    static func toCD(_ encrypted : Encrypted, context : NSManagedObjectContext) -> CoreData
}

/// Converts the stored Databases (e.g. Core Data) into
/// Encrypted Databases and back.
/// Works with Arrays.
internal struct DB_Converter : DatabaseConverterProtocol {
    
    internal static func fromCD(_ coreData: CD_Database) throws -> EncryptedDatabase {
        return try EncryptedDatabase(from: coreData)
    }

    internal static func fromCD(_ coreData : [CD_Database]) throws -> [EncryptedDatabase] {
        var result : [EncryptedDatabase] = []
        for db in coreData {
            result.append(try fromCD(db))
        }
        return result
    }
    
    internal static func toCD(_ encrypted: EncryptedDatabase, context: NSManagedObjectContext) -> CD_Database {
        let cdDB : CD_Database = CD_Database(context: context)
        cdDB.name = DataConverter.stringToData(encrypted.name)
        cdDB.objectDescription = DataConverter.stringToData(encrypted.description)
        for folder in encrypted.folders {
            cdDB.addToFolders(FolderConverter.toCD(folder, context: context))
        }
        for entry in encrypted.entries {
            cdDB.addToEntries(EntryConverter.toCD(entry, context: context))
        }
        for image in encrypted.images {
            cdDB.addToImages(ImageConverter.toCD(image, context: context))
        }
        cdDB.iconName = DataConverter.stringToData(encrypted.iconName)
        for doc in encrypted.documents {
            cdDB.addToDocuments(DocumentConverter.toCD(doc, context: context))
        }
        cdDB.created = DataConverter.dateToData(encrypted.created)
        cdDB.lastEdited = DataConverter.dateToData(encrypted.lastEdited)
        cdDB.header = encrypted.header.parseHeader()
        cdDB.key = encrypted.key
        cdDB.allowBiometrics = encrypted.allowBiometrics
        return cdDB
    }
}

/// Struct to convert Folders from encrypted to Core Data and backwards
private struct FolderConverter : DatabaseConverterProtocol {
    
    fileprivate static func fromCD(_ coreData: CD_Folder) -> EncryptedFolder {
        return EncryptedFolder(from: coreData)
    }
    
    fileprivate static func toCD(_ encrypted: EncryptedFolder, context: NSManagedObjectContext) -> CD_Folder {
        let cdFolder : CD_Folder = CD_Folder(context: context)
        cdFolder.name = encrypted.name
        cdFolder.objectDescription = encrypted.description
        for f in encrypted.folders {
            cdFolder.addToFolders(toCD(f, context: context))
        }
        for e in encrypted.entries {
            cdFolder.addToEntries(EntryConverter.toCD(e, context: context))
        }
        for image in encrypted.images {
            cdFolder.addToImages(ImageConverter.toCD(image, context: context))
        }
        cdFolder.iconName = encrypted.iconName
        for doc in encrypted.documents {
            cdFolder.addToDocuments(DocumentConverter.toCD(doc, context: context))
        }
        cdFolder.created = encrypted.created
        cdFolder.lastEdited = encrypted.lastEdited
        return cdFolder
    }
}

/// Struct to convert Entries from encrypted to Core Data and backwards
private struct EntryConverter : DatabaseConverterProtocol {
    
    fileprivate static func fromCD(_ coreData: CD_Entry) -> EncryptedEntry {
        return EncryptedEntry(from: coreData)
    }
    
    fileprivate static func toCD(_ encrypted: EncryptedEntry, context: NSManagedObjectContext) -> CD_Entry {
        let cdEntry : CD_Entry = CD_Entry(context: context)
        cdEntry.title = encrypted.title
        cdEntry.username = encrypted.username
        cdEntry.password = encrypted.password
        cdEntry.url = encrypted.url
        cdEntry.notes = encrypted.notes
        cdEntry.iconName = encrypted.iconName
        for doc in encrypted.documents {
            cdEntry.addToDocuments(DocumentConverter.toCD(doc, context: context))
        }
        cdEntry.created = encrypted.created
        cdEntry.lastEdited = cdEntry.lastEdited
        return cdEntry
    }
}

/// Struct to convert Images from encrypted to Core Data and backwards
private struct ImageConverter : DatabaseConverterProtocol {
    fileprivate static func fromCD(_ coreData: CD_Image) throws -> Encrypted_DB_Image {
        return Encrypted_DB_Image(from: coreData)
    }

    fileprivate static func toCD(_ encrypted: Encrypted_DB_Image, context: NSManagedObjectContext) -> CD_Image {
        let cdImage : CD_Image = CD_Image(context: context)
        cdImage.imageData = encrypted.image
        cdImage.dataType = encrypted.type
        cdImage.compressionQuality = encrypted.quality
        cdImage.created = encrypted.created
        cdImage.lastEdited = encrypted.lastEdited
        return cdImage
    }
}

/// Struct to convert Documents from encrypted to Core Data and backwards
private struct DocumentConverter : DatabaseConverterProtocol {
    static func fromCD(_ coreData: CD_Document) throws -> Encrypted_DB_Document {
        return Encrypted_DB_Document(from: coreData)
    }

    static func toCD(_ encrypted: Encrypted_DB_Document, context: NSManagedObjectContext) -> CD_Document {
        let cdDoc : CD_Document = CD_Document(context: context)
        cdDoc.documentData = encrypted.document
        cdDoc.type = encrypted.type
        cdDoc.created = encrypted.created
        cdDoc.lastEdited = encrypted.lastEdited
        return cdDoc
    }
}
