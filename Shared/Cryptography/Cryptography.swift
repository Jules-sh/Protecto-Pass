//
//  Cryptography.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 29.05.23.
//

import Foundation

internal enum CryptoStatus : Error {
    case errUnlocking
    case errLocking
    case unknownEncryption
}

internal struct Cryptography {
    
    /// An Enum representing the
    /// supported encryptions of this App
    internal enum Encryption : String, RawRepresentable, CaseIterable, Identifiable {
        var id: Self { self }
        
        /// Using AES 256 Bit for the Encryption and Decryption
        case AES256
        
        /// Using ChaCha20-Poly1305 for the Encryption and Decryption
        case ChaChaPoly
    }
    
    internal static func stringToData(_ string : String) -> Data {
        return Data(string.utf8.map { UInt8($0) })
    }
}
