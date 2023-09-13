//
//  DB_Header.swift
//  Protecto Pass
//
//  Created by Julian Schumacher as CD_DB_Header on 28.03.23.
//
//  Renamed by Julian Schumacher to DB_Header on 29.03.23.
//

import Foundation

/// The Header for an encrypted Database containing the
/// important information about the Database
internal struct DB_Header : Codable {
    
    /// The Check String to check if the Decryption of the Database has been successful
    internal static let checkString : String = "Protecto Pass is the top 1 App!"
    
    /// Parses a String and returns a Header
    internal static func parseString(string : String) throws -> DB_Header {
        let data : [Substring] = string.replacingOccurrences(of: " ", with: "").split(separator: ";")
        var result : [Substring] = []
        for s in data {
            let split : [Substring] = s.split(separator: ":")
            result.append(split[1])
        }
        let pathString : String = String(result[3])
        return DB_Header(
            encryption: Cryptography.Encryption(rawValue: String(result[0]))!,
            storageType: Storage.StorageType(rawValue: String(result[1]))!,
            salt: String(result[2]),
            path: pathString == "nil" ? nil : URL(string: String(result[3]))
        )
    }
    
    internal init(
        encryption : Cryptography.Encryption,
        storageType : Storage.StorageType,
        salt : String,
        path : URL? = nil
    ) {
        self.encryption = encryption
        self.storageType = storageType
        self.salt = salt
        self.path = path
    }
    
    ///The Enum telling the App
    ///which Encryption was used to encrypt
    ///the Database
    internal var encryption : Cryptography.Encryption
    
    /// The Enum telling the App how the Database
    /// is stored.
    internal var storageType : Storage.StorageType
    
    /// The Salt to secure the password of the database
    /// against rainbow attacks
    internal var salt : String
    
    /// The Path where to store the Database on
    /// the System or Cloud
    internal var path : URL?
    
    /// Parses this Header to a String which is ready to be stored
    internal func parseHeader() -> String {
        return "encryption: \(encryption.rawValue); storagetype: \(storageType.rawValue); salt: \(salt); path: \(path?.absoluteString ?? "nil")"
    }
    
    /// A preview header to use in previews and tests.
    /// The salt is still dynamically generated every time
    internal static let previewHeader : DB_Header = DB_Header(
        encryption: .AES256,
        storageType: .CoreData,
        salt: PasswordGenerator.generateSalt(),
        path: URL(string: "/")
    )
    
    private enum HeaderCodingKeys: CodingKey {
        case encryption
        case storageType
        case salt
        case path
    }
    
    internal func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: HeaderCodingKeys.self)
        try container.encode(encryption.rawValue, forKey: .encryption)
        try container.encode(storageType.rawValue, forKey: .storageType)
        try container.encode(salt, forKey: .salt)
        try container.encode(path, forKey: .path)
    }
    
    internal init(from decoder: Decoder) throws {
        let container : KeyedDecodingContainer = try decoder.container(keyedBy: HeaderCodingKeys.self)
        self.init(
            encryption: Cryptography.Encryption(rawValue: try container.decode(String.self, forKey: .encryption))!,
            storageType: Storage.StorageType(rawValue: try container.decode(String.self, forKey: .storageType))!,
            salt: try container.decode(String.self, forKey: .salt),
            path: try container.decode(URL?.self, forKey: .path)
        )
    }
}
