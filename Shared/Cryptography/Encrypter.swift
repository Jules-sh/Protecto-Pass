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
    
    /// The Database that should be encrypted.
    /// This is passed with the encrypt Method,
    /// and is used by the private methods
    private var db : Database?
    
    private let encryption : DB_Header.Encryption
    
    /// Returns the correct Encrypter for the passed database
    internal static func getInstance(for db : Database) -> Encrypter {
        if db.header.encryption == .AES256 {
            return aes256
        } else if db.header.encryption == .ChaChaPoly {
            return chaChaPoly
        } else {
            return Encrypter(encryption: .unknown)
        }
    }
    
    private init(encryption : DB_Header.Encryption) {
        
    }
    
    internal mutating func encrypt(db : Database) throws -> EncryptedDatabase {
        self.db = db
        if db.header.encryption == .AES256 {
            return try encryptAES()
        } else if db.header.encryption == .ChaChaPoly {
            return try encryptChaChaPoly()
        } else {
            throw EncryptionError.unknownEncryption
        }
    }
    
    private func encryptAES() throws -> EncryptedDatabase {
        
    }
    
    private func encryptChaChaPoly() throws -> EncryptedDatabase {
        
    }
}
