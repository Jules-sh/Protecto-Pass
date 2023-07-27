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
private protocol Converter {
    
    /// The Core Data type of the converter
    associatedtype CoreData : NSManagedObject
    
    /// The encrypted Type of the converter
    associatedtype Encrypted
    
    /// Converts the specified Core Data Object to an encrypted Object
    static func fromCD(_ coreData : CoreData) -> Encrypted
    
    /// Converts all the specified Core Data Objects to encrypted Objects
    static func fromCD(_ coreData : [CoreData]) -> [Encrypted]
    
    /// Converts the specified encrypted Object to a core Data Object
    static func toCD(_ encrypted : Encrypted, context : NSManagedObjectContext) -> CoreData
    
    /// Converts all the specified encrypted objects to core age Objects
    static func toCD(_ encrypted : [Encrypted], context : NSManagedObjectContext) -> [CoreData]
}

/// Converts the stored Databases (e.g. Core Data) into
/// Encrypted Databases and back.
/// Works with Arrays.
internal struct DB_Converter : Converter {
    
    internal static func fromCD(_ coreData: CD_Database) -> EncryptedDatabase {
        return EncryptedDatabase(from: coreData)
    }

    internal static func fromCD(_ coreData : [CD_Database]) -> [EncryptedDatabase] {
        var result : [EncryptedDatabase] = []
        for cdDatabase in coreData {
            result.append(fromCD(cdDatabase))
        }
        return result
    }
    
    internal static func toCD(_ encrypted: EncryptedDatabase, context: NSManagedObjectContext) -> CD_Database {
        let cdDB : CD_Database = CD_Database(context: context)
        cdDB.name = encrypted.name
        cdDB.dbDescription = encrypted.dbDescription
        cdDB.header = encrypted.header.parseHeader()
        for folder in encrypted.folders {
            cdDB.addToFolders(FolderConverter.toCD(folder, context: context))
        }
        return cdDB
    }
    
    internal static func toCD(_ dbs : [EncryptedDatabase], context : NSManagedObjectContext) -> [CD_Database] {
        var result : [CD_Database] = []
        for db in dbs {
            result.append(toCD(db, context: context))
        }
        return result
    }
}

private struct FolderConverter : Converter {
    
    fileprivate static func fromCD(_ coreData: CD_Folder) -> EncryptedFolder {
        return EncryptedFolder(from: coreData)
    }
    
    fileprivate static func fromCD(_ coreData: [CD_Folder]) -> [EncryptedFolder] {
        var result : [EncryptedFolder] = []
        for folder in coreData {
            result.append(fromCD(folder))
        }
        return result
    }
    
    fileprivate static func toCD(_ encrypted: EncryptedFolder, context: NSManagedObjectContext) -> CD_Folder {
        let cdFolder : CD_Folder = CD_Folder(context: context)
        cdFolder.name = encrypted.name
        for f in encrypted.folders {
            cdFolder.addToFolders(toCD(f, context: context))
        }
        for e in encrypted.entries {
            cdFolder.addToEntries(EntryConverter.toCD(e, context: context))
        }
        return cdFolder
    }
    
    fileprivate static func toCD(_ encrypted: [EncryptedFolder], context: NSManagedObjectContext) -> [CD_Folder] {
        var result : [CD_Folder] = []
        for folder in encrypted {
            result.append(toCD(folder, context: context))
        }
        return result
    }
}

private struct EntryConverter : Converter {
    
    fileprivate static func fromCD(_ coreData: CD_Entry) -> EncryptedEntry {
        return EncryptedEntry(from: coreData)
    }
    
    fileprivate static func fromCD(_ coreData: [CD_Entry]) -> [EncryptedEntry] {
        var result : [EncryptedEntry] = []
        for entry in coreData {
            result.append(fromCD(entry))
        }
        return result
    }
    
    fileprivate static func toCD(_ encrypted: EncryptedEntry, context: NSManagedObjectContext) -> CD_Entry {
        let cdEntry : CD_Entry = CD_Entry(context: context)
        cdEntry.title = encrypted.title
        cdEntry.username = encrypted.username
        cdEntry.password = encrypted.password
        cdEntry.url = encrypted.url
        cdEntry.notes = encrypted.notes
        return cdEntry
    }
    
    fileprivate static func toCD(_ encrypted: [EncryptedEntry], context: NSManagedObjectContext) -> [CD_Entry] {
        var result : [CD_Entry] = []
        for entry in encrypted {
            result.append(toCD(entry, context: context))
        }
        return result
    }
}
