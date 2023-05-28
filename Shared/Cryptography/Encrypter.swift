//
//  Encrypter.swift
//  Protecto Pass
//
//  Created by Julian Schumacher as Encoder.swift on 07.05.23.
//
//  Renamed by Julian Schumacher to Encrypter.swift on 27.05.23.
//

import Foundation

internal struct Encrypter {
    
    private static let aes256 : Encrypter = Encrypter(encryption: .AES256)
    
    private static let chaChaPoly : Encrypter = Encrypter(encryption: .ChaChaPoly)
    
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
    
    internal func encrypt(db : Database) throws -> EncryptedDatabase {
        
    }
}
