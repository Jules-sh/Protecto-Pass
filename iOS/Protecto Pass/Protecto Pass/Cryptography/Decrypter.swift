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
    
    internal func decryptDatabase(db : CD_Database) throws -> Database {
        
    }
    
    private func decryptFolder(folder : CD_Folder) throws -> Folder {
        
    }
    
    private func decryptEntry(entry : CD_Entry) throws -> Entry {
        
    }
}
