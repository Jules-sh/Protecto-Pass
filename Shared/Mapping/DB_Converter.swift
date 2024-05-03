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
        for toc in encrypted.contents {
            cdDB.addToContents(ToC_Converter.toCD(toc, context: context))
        }
        cdDB.iconName = DataConverter.stringToData(encrypted.iconName)
        cdDB.created = DataConverter.dateToData(encrypted.created)
        cdDB.lastEdited = DataConverter.dateToData(encrypted.lastEdited)
        cdDB.header = encrypted.header.parseHeader()
        cdDB.key = encrypted.key
        cdDB.allowBiometrics = encrypted.allowBiometrics
        cdDB.uuid = encrypted.id
        return cdDB
    }
}


internal struct ToC_Converter : DatabaseConverterProtocol {
    static func fromCD(_ coreData: CD_ToCItem) throws -> EncryptedToCItem {
        return EncryptedToCItem(from: coreData)
    }
    
    static func toCD(_ encrypted: EncryptedToCItem, context: NSManagedObjectContext) -> CD_ToCItem {
        let cdToC : CD_ToCItem = CD_ToCItem(context: context)
        cdToC.name = encrypted.name
        cdToC.type = encrypted.type.rawValue
        cdToC.uuid = encrypted.id
        return cdToC
    }
}
