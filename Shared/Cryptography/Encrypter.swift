//
//  Encrypter.swift
//  Protecto Pass
//
//  Created by Julian Schumacher as Encoder.swift on 07.05.23.
//
//  Renamed by Julian Schumacher to Encrypter.swift on 27.05.23.
//

import Foundation

internal enum EncryptionError : Error {
    case errLocking
    case unknownEncryption
}

/// Struct used to encypt Databases into encrypted Databases
internal struct Encrypter {
    
    /// Encrypter specified for AES 256 Bit Encryption
    private static let aes256 : Encrypter = Encrypter(encryption: .AES256)
    
    /// Encrypter specified for ChaChaPoly Encryption
    private static let chaChaPoly : Encrypter = Encrypter(encryption: .ChaChaPoly)
    
    /// Returns the correct Encrypter for the passed database
    internal static func getInstance(for db : Database) -> Encrypter {
        var encrypter : Encrypter
        if db.header.encryption == .AES256 {
            encrypter = aes256
        } else if db.header.encryption == .ChaChaPoly {
            encrypter = chaChaPoly
        } else {
            encrypter = Encrypter(encryption: .unknown)
        }
        encrypter.db = db
        return encrypter
    }
    
    /// The Encryption that is used for this Encrypter
    private let encryption : DB_Header.Encryption
    
    /// The Database that should be encrypted.
    /// This is passed with the encrypt Method,
    /// and is used by the private methods
    private var db : Database?
    
    private init(encryption : DB_Header.Encryption) {
        self.encryption = encryption
    }
    
    internal func encrypt() throws -> EncryptedDatabase {
        if encryption == .AES256 {
            return try encryptAES()
        } else if encryption == .ChaChaPoly {
            return try encryptChaChaPoly()
        } else {
            throw EncryptionError.unknownEncryption
        }
    }
    
    /// Encrypts Databases with AES
    /// Throws an Error if something went wrong
    private func encryptAES() throws -> EncryptedDatabase {
        
    }
    
    /// Encrypts Databases with ChaChaPoly
    /// Throws an Error if something went wrong
    private func encryptChaChaPoly() throws -> EncryptedDatabase {
        
    }
}
