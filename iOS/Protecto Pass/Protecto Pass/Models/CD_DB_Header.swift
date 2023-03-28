//
//  CD_DB_Header.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 28.03.23.
//

import Foundation

/// The Header for an encrypted Database containing the
/// important information about the Database
internal struct CD_DB_Header {
    
    /// The Enum to choose which
    /// encryption was used to encrypt
    /// the database and correspondingly
    /// has to be used to encrypt it
    internal enum Encryption : String, RawRepresentable {
        case AES256
    }
    
    /// The Check String to check if the Decryption of the Database has been successful
    internal let checkString : String = "Protecto Pass is a great App"
    
    ///The Enum telling the App
    ///which Encryption was used to encrypt
    ///the Database
    internal var encryption : Encryption = .AES256
    
    /// Parses a String and returns a Header
    internal static func parseString(string : String) -> CD_DB_Header {
        let data : [Substring] = string.split(separator: ";")
        // TODO: data[0] or where("encryption:")?
        return CD_DB_Header(encryption: Encryption(rawValue: String(data[0]))!)
    }
    
    /// Parses this Header to a String which is ready to be stored
    internal func parseHeader() -> String {
        return "encryption: \(encryption.rawValue);"
    }
}
