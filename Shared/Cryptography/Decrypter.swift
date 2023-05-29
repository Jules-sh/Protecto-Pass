//
//  Decrypter.swift
//  Protecto Pass
//
//  Created by Julian Schumacher as Decoder.swift on 07.05.23.
//
//  Renamed by Julian Schumacher to Decrypter.swift on 27.05.23.
//

import CryptoKit
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
    
    /// Returns the correct Decrypter for the passed database
    internal static func getInstance(for db : EncryptedDatabase) -> Decrypter {
        var decrypter : Decrypter
        if db.header.encryption == .AES256 {
            decrypter = aes256
        } else if db.header.encryption == .ChaChaPoly {
            decrypter = chaChaPoly
        } else {
            decrypter = Decrypter(encryption: .unknown)
        }
        decrypter.db = db
        return decrypter
    }
    
    /// The Encryption that is used for this Decrypter
    private let encryption : Cryptography.Encryption
    
    /// The Database that should be decrypted.
    /// This is passed with the decrypt Method,
    /// and is used by the private methods
    private var db : EncryptedDatabase?
    
    /// Private init, to prevent creating this Object.
    /// Only use getInstance with the database you want to decrypt
    private init(encryption : Cryptography.Encryption) {
        self.encryption = encryption
    }
    
    /// Decrypts the Database this Encrypter is configured for,
    /// using the getInstance method and passing your Database.
    /// Returns the encrypted Database if it could be encrypted, otherwise
    /// throws an error.
    /// See Error for more details
    internal func decrypt() throws -> Database {
        if encryption == .AES256 {
            return try decryptAES()
        } else if encryption == .ChaChaPoly {
            return try decryptChaChaPoly()
        } else {
            throw CryptoStatus.unknownEncryption
        }
    }
    
    /// Decrypts AES encrypted Databases
    /// /// Throws an Error if something went wrong
    private func decryptAES() throws -> Database {
        
    }
    
    /// Decrypts ChaChaPoly Encrypted Databases
    /// Throws an Error if something went wrong
    private func decryptChaChaPoly() throws -> Database {
        
    }
}
