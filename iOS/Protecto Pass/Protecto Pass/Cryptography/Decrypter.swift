//
//  Decrypter.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 28.03.23.
//

import Foundation

/// Struct used to decrypt Data and FIles / Objects
/// used in this App
internal struct Decrypter {
    
    /// The Decrypter being used for aes 256 Decryption
    internal static let aes256 : Decrypter = Decrypter()
    
    private func decryptDatabase(_ db : EncryptedDatabase) throws -> Database {
        
    }
    
    private func decryptFolder(_ folder : EncryptedFolder) throws -> Folder {
        
    }
    
    private func decryptEntry(_ entry : EncryptedEntry) throws -> Entry {
        
    }
}
