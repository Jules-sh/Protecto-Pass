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
}

internal struct Decrypter {
    
    private static let aes256 : Decrypter = Decrypter(encryption: .AES256)
    
    private static let chaChaPoly : Decrypter = Decrypter(encryption: .ChaChaPoly)
    
    internal static func getInstance(for db : EncryptedDatabase) -> Decrypter {
        if db.header.encryption == .AES256 {
            return aes256
        } else if db.header.encryption == .ChaChaPoly {
            return chaChaPoly
        } else {
            return Decrypter(encryption: .unknown)
        }
    }
    
    private init(encryption : DB_Header.Encryption) {
        
    }
    
    internal func decrypt(db : EncryptedDatabase) throws -> Database {
        
    }
    
    private func decryptAES(db : EncryptedDatabase) throws -> Database {
        
    }
    
    private func decryptChaChaPoly(db : EncryptedDatabase) throws -> Database {
        
    }
}
