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
    
    /// This is the symmetric Key used to
    /// decrypt the Database
    private var key : SymmetricKey?
    
    /// Private init, to prevent creating this Object.
    /// Only use getInstance with the database you want to decrypt
    private init(encryption : Cryptography.Encryption) {
        self.encryption = encryption
    }
    
    /// Decrypts the Database this Decrypter is configured for,
    /// using the getInstance method and passing your Database.
    /// Returns the decrypted Database if it could be decrypted, otherwise
    /// throws an error.
    /// See Error for more details
    internal mutating func decrypt(using password : String) throws -> Database {
        key = SymmetricKey(data: password.data(using: .utf8)!)
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
        var decryptedFolders : [Folder] = []
        for folder in db!.folders {
            decryptedFolders.append(try decryptAES(folder: folder))
        }
        let decryptedDatabase : Database = Database(
            name: db!.name,
            dbDescription: db!.dbDescription,
            folders: decryptedFolders,
            header: db!.header
        )
        return decryptedDatabase
    }
    
    private func decryptAES(folder : EncryptedFolder) throws -> Folder {
    }
    
    private func decryptAES(entry : EncryptedEntry) throws -> Entry {
    }
    
    /// Decrypts ChaChaPoly Encrypted Databases
    /// Throws an Error if something went wrong
    private func decryptChaChaPoly() throws -> Database {
        
    }
    
    private func decryptChaChaPoly(folder : EncryptedFolder) throws -> Folder {
    }
    
    private func decryptChaChaPoly(entry : EncryptedEntry) throws -> Entry {
    }
}
