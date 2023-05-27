//
//  DB_Converter.swift
//  Protecto Pass
//
//  Created by Julian Schumacher as CD_Mapping.swift on 27.05.23.
//
//  Renamed by Julian Schumacher to DB_Converter.swift on 27.05.23.
//

import Foundation

/// Converts the stored Databases (e.g. Core Data) into
/// Encrypted Databases and back.
/// Works with Arrays.
internal struct DB_Converter {
    
    internal func fromCD(_ coreData : [CD_Database]) -> [EncryptedDatabase] {
        var result : [EncryptedDatabase] = []
        for cdDatabase in coreData {
            result.append(EncryptedDatabase(from: cdDatabase))
        }
        return result
    }
    
    internal func toCD(_ dbs : [EncryptedDatabase]) -> [CD_Database] {
        var result : [CD_Database] = []
        for db in dbs {
            // TODO: add Code
        }
        return result
    }
}
