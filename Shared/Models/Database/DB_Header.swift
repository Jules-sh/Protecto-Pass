//
//  DB_Header.swift
//  Protecto Pass
//
//  Created by Julian Schumacher as CD_DB_Header on 28.03.23.
//
//  Renamed by Julian Schumacher to DB_Header on 29.03.23.
//

import Foundation

/// The Header for an encrypted Database containing the
/// important information about the Database
internal struct DB_Header {
    
    /// The Enum to declare how the Database is stored.
    internal enum StorageType : String, RawRepresentable, CaseIterable, Identifiable {
        var id : Self { self }
        
        /// Storing this Database as an encrypted Core Data Instance
        case CoreData
        
        /// Storing this Database in an local encrypted binary File
        case File
        
        /// Storing this Database only local in the Keychain.
        case Keychain
    }
    
    /// The Check String to check if the Decryption of the Database has been successful
    internal static let checkString : String = "Protecto Pass is the top 1 App!"
    
    /// Parses a String and returns a Header
    internal static func parseString(string : String) -> DB_Header {
        let data : [Substring] = string.replacingOccurrences(of: " ", with: "").split(separator: ";")
        var result : [Substring] = []
        for s in data {
            let split : [Substring] = s.split(separator: ":")
            result.append(split[1])
        }
        return DB_Header(
            encryption: Cryptography.Encryption(rawValue: String(result[0]))!,
            storageType: StorageType(rawValue: String(result[1]))!,
            salt: String(result[2])
        )
    }
    
    ///The Enum telling the App
    ///which Encryption was used to encrypt
    ///the Database
    internal var encryption : Cryptography.Encryption = .AES256
    
    /// The Enum telling the App how the Database
    /// is stored.
    internal var storageType : StorageType = .CoreData
    
    /// The Salt to secure the password of the database
    /// against rainbow attacks
    internal var salt : String
    
    /// Parses this Header to a String which is ready to be stored
    internal func parseHeader() -> String {
        return "encryption: \(encryption.rawValue); storagetype: \(storageType.rawValue); salt: \(salt)"
    }
}
