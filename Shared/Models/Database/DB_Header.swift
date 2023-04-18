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
    
    /// The Enum to choose which
    /// encryption was used to encrypt
    /// the database and correspondingly
    /// has to be used to decrypt it
    internal enum Encryption : String, RawRepresentable {
        /// Using AES 256 Bit for the Encryption and Decryption
        case AES256
        
        /// Using ChaCha20-Poly1305 for the Encryption and Decryption
        case ChaChaPoly
    }
    
    /// The Enum to declare how the Database is stored.
    internal enum StorageType : String, RawRepresentable {
        /// Storing this Database in an local encrypted binary File
        case File
        
        /// Storing this Database as an encrypted Core Data Instance
        case CoreData
        
        /// Storing this Database only local in the Keychain.
        case Keychain
        
        /// Storing this Database in a sealed Box via ChaCha Poly Algorithm
        case SealedBox
    }
    
    /// The Check String to check if the Decryption of the Database has been successful
    internal static let checkString : String = "Protecto Pass is a great App"
    
    ///The Enum telling the App
    ///which Encryption was used to encrypt
    ///the Database
    internal var encryption : Encryption = .AES256
    
    /// The Enum telling the App how the Database
    /// is stored.
    internal var storageType : StorageType = .CoreData
    
    /// Parses a String and returns a Header
    internal static func parseString(string : String) -> DB_Header {
        var data : [Substring] = string.replacingOccurrences(of: " ", with: "").split(separator: ";")
        // TODO: data[0] or where("encryption:")?
        for s in data {
            var split : [Substring] = s.split(separator: ":")
            for i in 0..<split.count where i % 2 != 0 {
                split.remove(at: i)
            }
            data = split
        }
        return DB_Header(encryption: Encryption(rawValue: String(data[0]))!)
    }
    
    /// Parses this Header to a String which is ready to be stored
    internal func parseHeader() -> String {
        return "encryption: \(encryption.rawValue); storagetype: \(storageType.rawValue)"
    }
}
