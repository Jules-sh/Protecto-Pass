//
//  Encrypter.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 28.03.23.
//

import Foundation

/// Struct used to encrypt Data and
/// Files / Objets in this App
internal struct Encrypter {
    
    /// The Cryptographic algorithm used in
    /// this Encrypter to encrypt everything put into it
    private let encryption : DB_Header.Encryption
    
    /// The Storage Type, of how the output data should be stored.
    /// This is relevant, because you have to adjust the output of the method
    private let storageType : DB_Header.StorageType
    
    /// The Initializer to initialize a new Encrypter with the specified
    /// custom data, rather than using one of the provided default encryptors
    internal init(encryption : DB_Header.Encryption, storageType : DB_Header.StorageType) {
        self.encryption = encryption
        self.storageType = storageType
    }
    
    /// The Encrypter being used for aes 256 Encryption
    internal static let cd_aes256 : Encrypter = Encrypter(encryption: .AES256, storageType: .CoreData)
    
    private func encryptDatabase(_ db : Database) -> EncryptedDatabase {
        
    }
    
    private func encryptFolder(_ folder : Folder) -> EncryptedFolder {
        
    }
    
    private func encryptEntry(_ entry : Entry) -> EncryptedEntry {
        
    }
}
