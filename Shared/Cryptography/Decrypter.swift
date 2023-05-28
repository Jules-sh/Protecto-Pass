//
//  Decrypter.swift
//  Protecto Pass
//
//  Created by Julian Schumacher as Decoder.swift on 07.05.23.
//
//  Renamed by Julian Schumacher to Decrypter.swift on 27.05.23.
//

import Foundation

internal enum DecryptionError : Error {
    case errUnlocking
    case unknownEncryption
}

internal struct Decrypter {
    
    /// Decrypter specified for AES 256 Bit Encryption
    private static let aes256 : Decrypter = Decrypter(encryption: .AES256)
    
    /// Decrypter specified for ChaChaPoly Encryption
    private static let chaChaPoly : Decrypter = Decrypter(encryption: .ChaChaPoly)
    
    private let encryption : DB_Header.Encryption
    
    /// The Database that should be decrypted.
    /// This is passed with the decrypt Method,
    /// and is used by the private methods
    private var db : EncryptedDatabase?
    
    /// Returns the correct Decrypter for the passed database
    internal static func getInstance(for db : EncryptedDatabase) -> Decrypter {
        self.db = db
        if db.header.encryption == .AES256 {
            return aes256
        } else if db.header.encryption == .ChaChaPoly {
            return chaChaPoly
        } else {
            return Decrypter(encryption: .unknown)
        }
    }
    
    private init(encryption : DB_Header.Encryption) {
        self.encryption = encryption
    }
    
    internal mutating func decrypt() throws -> Database {
        if encryption == .AES256 {
            return try decryptAES()
        } else if encryption == .ChaChaPoly {
            return try decryptChaChaPoly()
        } else {
            throw DecryptionError.unknownEncryption
        }
    }
    
    private func decryptAES() throws -> Database {
        
    }
    
    private func decryptChaChaPoly() throws -> Database {
        
    }
}
