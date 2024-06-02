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
import UIKit

/// Decrypter to decrypt a Database and all it's components
internal struct Decrypter {
    
    /// Decrypter specified for AES 256 Bit Encryption
    private static let aes256 : Decrypter = Decrypter(encryption: .AES256)
    
    /// Decrypter specified for ChaChaPoly Encryption
    private static let chaChaPoly : Decrypter = Decrypter(encryption: .ChaChaPoly)
    
    /// Returns the correct Decrypter for the passed database
    internal static func configure(for db : EncryptedDatabase, with password : String) -> Decrypter {
        var decrypter : Decrypter
        if db.header.encryption == .AES256 {
            decrypter = aes256
        } else if db.header.encryption == .ChaChaPoly {
            decrypter = chaChaPoly
        } else {
            decrypter = Decrypter(encryption: nil)
        }
        decrypter.password = password + db.header.salt
        decrypter.userPassword = password
        decrypter.db = db
        return decrypter
    }
    
    /// The Encryption that is used for this Decrypter
    private let encryption : Cryptography.Encryption?
    
    /// The Database that should be decrypted.
    /// This is passed with the decrypt Method,
    /// and is used by the private methods
    private var db : EncryptedDatabase?
    
    /// This is the symmetric Key used to
    /// decrypt the Database
    private var key : SymmetricKey?
    
    /// The Password the user entered.
    private var userPassword : String?
    
    /// The Password created by adding the salt of
    /// the Database to the userPassword
    private var password : String?
    
    /// Private init, to prevent creating this Object.
    /// Only use getInstance with the database you want to decrypt
    private init(encryption : Cryptography.Encryption?) {
        self.encryption = encryption
    }
    
    // START GENERAL DECRYPTION
    
    /// Decrypts the passed Folder with the cryptography algorithm this Decrypter is configured for.
    /// Use the `configure` Method to configure a Decrypter
    internal func decryptFolder(_ folder : EncryptedFolder) throws -> Folder {
        if db!.header.encryption == .AES256 {
            return try decryptAES(folder: folder)
        } else if db!.header.encryption == .ChaChaPoly {
            return try decryptChaChaPoly(folder: folder)
        } else {
            throw CryptoStatus.unknownEncryption
        }
    }
    
    /// Decrypts the passed Entry with the cryptography algorithm this Decrypter is configured for.
    /// Use the `configure` Method to configure a Decrypter
    internal func decryptEntry(_ entry : EncryptedEntry) throws -> Entry {
        if db!.header.encryption == .AES256 {
            return try decryptAES(entry: entry)
        } else if db!.header.encryption == .ChaChaPoly {
            return try decryptChaChaPoly(entry: entry)
        } else {
            throw CryptoStatus.unknownEncryption
        }
    }
    
    /// Decrypts the passed Image with the cryptography algorithm this Decrypter is configured for.
    /// Use the `configure` Method to configure a Decrypter
    internal func decryptImage(_ image : Encrypted_DB_Image) throws -> DB_Image {
        if db!.header.encryption == .AES256 {
            return try decryptAES(image: image)
        } else if db!.header.encryption == .ChaChaPoly {
            return try decryptChaChaPoly(image: image)
        } else {
            throw CryptoStatus.unknownEncryption
        }
    }
    
    /// Decrypts the passed Video with the cryptography algorithm this Decrypter is configured for.
    /// Use the `configure` Method to configure a Decrypter
    internal func decryptVideo(_ video : Encrypted_DB_Video) throws -> DB_Video {
        if db!.header.encryption == .AES256 {
            return try decryptAES(video: video)
        } else if db!.header.encryption == .ChaChaPoly {
            return try decryptChaChaPoly(video: video)
        } else {
            throw CryptoStatus.unknownEncryption
        }
    }
    
    /// Decrypts the passed Document with the cryptography algorithm this Decrypter is configured for.
    /// Use the `configure` Method to configure a Decrypter
    internal func decryptDocument(_ document : Encrypted_DB_Document) throws -> DB_Document {
        if db!.header.encryption == .AES256 {
            return try decryptAES(document: document)
        } else if db!.header.encryption == .ChaChaPoly {
            return try decryptChaChaPoly(document: document)
        } else {
            throw CryptoStatus.unknownEncryption
        }
    }
    
    // START AES DECRYPTION
    
    /// Decrypts AES encrypted Databases
    private mutating func decryptAES() throws -> Database {
        key = try decryptAESKey()
        return Database(
            name: db!.name,
            description: db!.description,
            iconName: db!.iconName,
            created: db!.created,
            lastEdited: db!.lastEdited,
            header: db!.header,
            key: key!,
            password: userPassword!,
            allowBiometrics: db!.allowBiometrics,
            id: db!.id
        )
    }
    
    /// Decrypts the key to use to decrypt the rest of the database using AES
    private func decryptAESKey() throws -> SymmetricKey {
        let data : Data = try AES.GCM.open(
            AES.GCM.SealedBox(combined: db!.key),
            using: SymmetricKey(data: Cryptography.sha256HashBytes(password!))
        )
        return SymmetricKey(data: data)
    }
    
    /// Decrypts the passed Folder using AES and returns an decrypted Folder
    private func decryptAES(folder : EncryptedFolder) throws -> Folder {
        let decryptedName : Data = try AES.GCM.open(
            try AES.GCM.SealedBox(combined: folder.name),
            using: key!
        )
        let decryptedDescription : Data = try AES.GCM.open(
            try AES.GCM.SealedBox(combined: folder.description),
            using: key!
        )
        let decryptedIconName : Data = try AES.GCM.open(
            try AES.GCM.SealedBox(combined: folder.iconName),
            using: key!
        )
        let decryptedCreatedDate : Data = try AES.GCM.open(
            try AES.GCM.SealedBox(combined: folder.created),
            using: key!
        )
        let decryptedLastEditedDate : Data = try AES.GCM.open(
            try AES.GCM.SealedBox(combined: folder.lastEdited),
            using: key!
        )
        return Folder(
            name: DataConverter.dataToString(decryptedName),
            description: DataConverter.dataToString(decryptedDescription),
            iconName: DataConverter.dataToString(decryptedIconName),
            created: try DataConverter.dataToDate(decryptedCreatedDate),
            lastEdited: try DataConverter.dataToDate(decryptedLastEditedDate),
            id: folder.id
        )
    }
    
    /// Decrypts the passed Entry using AES and returns and decrypted Entry
    private func decryptAES(entry : EncryptedEntry) throws -> Entry {
        let decryptedTitle : Data = try AES.GCM.open(
            try AES.GCM.SealedBox(combined: entry.title),
            using: key!
        )
        let decryptedUsername : Data = try AES.GCM.open(
            try AES.GCM.SealedBox(combined: entry.username),
            using: key!
        )
        let decryptedPassword = try AES.GCM.open(
            try AES.GCM.SealedBox(combined: entry.password),
            using: key!
        )
        let decryptedURL = try AES.GCM.open(
            try AES.GCM.SealedBox(combined: entry.url),
            using: key!
        )
        let decryptedNotes : Data = try AES.GCM.open(
            try AES.GCM.SealedBox(combined: entry.notes),
            using: key!
        )
        let decryptedIconName : Data = try AES.GCM.open(
            try AES.GCM.SealedBox(combined: entry.iconName),
            using: key!
        )
        let decryptedCreatedDate : Data = try AES.GCM.open(
            try AES.GCM.SealedBox(combined: entry.created),
            using: key!
        )
        let decryptedLastEditedDate : Data = try AES.GCM.open(
            try AES.GCM.SealedBox(combined: entry.lastEdited),
            using: key!
        )
        return Entry(
            title: DataConverter.dataToString(decryptedTitle),
            username: DataConverter.dataToString(decryptedUsername),
            password: DataConverter.dataToString(decryptedPassword),
            url: URL(string: DataConverter.dataToString(decryptedURL)),
            notes: DataConverter.dataToString(decryptedNotes),
            iconName: DataConverter.dataToString(decryptedIconName),
            created: try DataConverter.dataToDate(decryptedCreatedDate),
            lastEdited: try DataConverter.dataToDate(decryptedLastEditedDate),
            id: entry.id
        )
    }
    
    /// Decrypts the passed Image using AES and returns a decrypted Image
    private func decryptAES(image : Encrypted_DB_Image) throws -> DB_Image {
        let decryptedImageData : Data = try AES.GCM.open(
            try AES.GCM.SealedBox(combined: image.image),
            using: key!
        )
        let decryptedQuality : Double = DataConverter.dataToDouble(
            try AES.GCM.open(
                AES.GCM.SealedBox(combined: image.quality),
                using: key!
            )
        )
        let decryptedCreatedDate : Data = try AES.GCM.open(
            AES.GCM.SealedBox(combined: image.created),
            using: key!
        )
        let decryptedLastEditedDate : Data = try AES.GCM.open(
            AES.GCM.SealedBox(combined: image.lastEdited),
            using: key!
        )
        return DB_Image(
            image: UIImage(data: decryptedImageData)!,
            quality: decryptedQuality,
            created: try DataConverter.dataToDate(decryptedCreatedDate),
            lastEdited: try DataConverter.dataToDate(decryptedLastEditedDate),
            id: image.id
        )
    }
    
    /// Decrypts the passed Video using AES and returns a decrypted Image
    private func decryptAES(video : Encrypted_DB_Video) throws -> DB_Video {
        let decryptedVideoData : Data = try AES.GCM.open(
            try AES.GCM.SealedBox(combined: video.video),
            using: key!
        )
        let decryptedCreatedDate : Data = try AES.GCM.open(
            AES.GCM.SealedBox(combined: video.created),
            using: key!
        )
        let decryptedLastEditedDate : Data = try AES.GCM.open(
            AES.GCM.SealedBox(combined: video.lastEdited),
            using: key!
        )
        return DB_Video(
            video: decryptedVideoData,
            created: try DataConverter.dataToDate(decryptedCreatedDate),
            lastEdited: try DataConverter.dataToDate(decryptedLastEditedDate),
            id: video.id
        )
    }
    
    /// Decrypts the passed document using AES and returns a decrypted Document
    private func decryptAES(document : Encrypted_DB_Document) throws -> DB_Document {
        let decryptedDocumentData : Data = try AES.GCM.open(
            try AES.GCM.SealedBox(combined: document.document),
            using: key!
        )
        let decryptedType : Data = try AES.GCM.open(
            try AES.GCM.SealedBox(combined: document.type),
            using: key!
        )
        let decryptedCreatedDate : Data = try AES.GCM.open(
            AES.GCM.SealedBox(combined: document.created),
            using: key!
        )
        let decryptedLastEditedDate : Data = try AES.GCM.open(
            AES.GCM.SealedBox(combined: document.lastEdited),
            using: key!
        )
        return DB_Document(
            document: decryptedDocumentData,
            type: DataConverter.dataToString(decryptedType),
            created: try DataConverter.dataToDate(decryptedCreatedDate),
            lastEdited: try DataConverter.dataToDate(decryptedLastEditedDate),
            id: document.id
        )
    }
    
    
    // START ChaChaPoly DECRYPTION
    
    /// Decrypts ChaChaPoly Encrypted Databases
    /// Throws an Error if something went wrong
    private mutating func decryptChaChaPoly() throws -> Database {
        key = try decryptChaChaPolyKey()
        let decryptedDatabase : Database = Database(
            name: db!.name,
            description: db!.description,
            iconName: db!.iconName,
            created: db!.created,
            lastEdited: db!.lastEdited,
            header: db!.header,
            key: key!,
            password: userPassword!,
            allowBiometrics: db!.allowBiometrics,
            id: db!.id
        )
        return decryptedDatabase
    }
    
    /// Decrypts the key to use to decrypt the rest of the database using ChaChaPoly
    private func decryptChaChaPolyKey() throws -> SymmetricKey {
        let data : Data = try ChaChaPoly.open(
            ChaChaPoly.SealedBox(combined: db!.key),
            using: SymmetricKey(data: Cryptography.sha256HashBytes(password!))
        )
        return SymmetricKey(data: data)
    }
    
    /// Decrypts the passed Folder with ChaChaPoly and returns
    /// an Folder
    private func decryptChaChaPoly(folder : EncryptedFolder) throws -> Folder {
        let decryptedName : Data = try ChaChaPoly.open(
            ChaChaPoly.SealedBox(combined: folder.name),
            using: key!
        )
        let decryptedDescription : Data = try ChaChaPoly.open(
            ChaChaPoly.SealedBox(combined: folder.description),
            using: key!
        )
        let decryptedIconName : Data = try ChaChaPoly.open(
            ChaChaPoly.SealedBox(combined: folder.iconName),
            using: key!
        )
        let decryptedCreatedDate : Data = try ChaChaPoly.open(
            ChaChaPoly.SealedBox(combined: folder.created),
            using: key!
        )
        let decryptedLastEditedDate : Data = try ChaChaPoly.open(
            ChaChaPoly.SealedBox(combined: folder.lastEdited),
            using: key!
        )
        return Folder(
            name: DataConverter.dataToString(decryptedName),
            description: DataConverter.dataToString(decryptedDescription),
            iconName: DataConverter.dataToString(decryptedIconName),
            created: try DataConverter.dataToDate(decryptedCreatedDate),
            lastEdited: try DataConverter.dataToDate(decryptedLastEditedDate),
            id: folder.id
        )
    }
    
    /// Decryptes the passed Entry with ChaChaPoly and returns an Entry
    private func decryptChaChaPoly(entry : EncryptedEntry) throws -> Entry {
        let decryptedTitle : Data = try ChaChaPoly.open(
            try ChaChaPoly.SealedBox(combined: entry.title),
            using: key!
        )
        let decryptedUsername : Data = try ChaChaPoly.open(
            try ChaChaPoly.SealedBox(combined: entry.username),
            using: key!
        )
        let decryptedPassword = try ChaChaPoly.open(
            try ChaChaPoly.SealedBox(combined: entry.password),
            using: key!
        )
        let decryptedURL = try ChaChaPoly.open(
            try ChaChaPoly.SealedBox(combined: entry.url),
            using: key!
        )
        let decryptedNotes : Data = try ChaChaPoly.open(
            try ChaChaPoly.SealedBox(combined: entry.notes),
            using: key!
        )
        let decryptedIconName : Data = try ChaChaPoly.open(
            ChaChaPoly.SealedBox(combined: entry.iconName),
            using: key!
        )
        let decryptedCreatedDate : Data = try ChaChaPoly.open(
            ChaChaPoly.SealedBox(combined: entry.created),
            using: key!
        )
        let decryptedLastEditedDate : Data = try ChaChaPoly.open(
            ChaChaPoly.SealedBox(combined: entry.lastEdited),
            using: key!
        )
        return Entry(
            title: DataConverter.dataToString(decryptedTitle),
            username: DataConverter.dataToString(decryptedUsername),
            password: DataConverter.dataToString(decryptedPassword),
            url: URL(string: DataConverter.dataToString(decryptedURL)),
            notes: DataConverter.dataToString(decryptedNotes),
            iconName: DataConverter.dataToString(decryptedIconName),
            created: try DataConverter.dataToDate(decryptedCreatedDate),
            lastEdited: try DataConverter.dataToDate(decryptedLastEditedDate),
            id: entry.id
        )
    }
    
    private func decryptChaChaPoly(image : Encrypted_DB_Image) throws -> DB_Image {
        let decryptedImageData : Data = try ChaChaPoly.open(
            try ChaChaPoly.SealedBox(combined: image.image),
            using: key!
        )
        let decryptedQuality : Double = DataConverter.dataToDouble(
            try ChaChaPoly.open(
                ChaChaPoly.SealedBox(combined: image.quality),
                using: key!
            )
        )
        let decryptedCreatedDate : Data = try ChaChaPoly.open(
            ChaChaPoly.SealedBox(combined: image.created),
            using: key!
        )
        let decryptedLastEditedDate : Data = try ChaChaPoly.open(
            ChaChaPoly.SealedBox(combined: image.lastEdited),
            using: key!
        )
        return DB_Image(
            image: UIImage(data: decryptedImageData)!,
            quality: decryptedQuality,
            created: try DataConverter.dataToDate(decryptedCreatedDate),
            lastEdited: try DataConverter.dataToDate(decryptedLastEditedDate),
            id: image.id
        )
    }
    
    /// Decrypts the passed Video using ChaChaPoly and returns a decrypted Image
    private func decryptChaChaPoly(video : Encrypted_DB_Video) throws -> DB_Video {
        let decryptedVideoData : Data = try ChaChaPoly.open(
            ChaChaPoly.SealedBox(combined: video.video),
            using: key!
        )
        let decryptedCreatedDate : Data = try ChaChaPoly.open(
            ChaChaPoly.SealedBox(combined: video.created),
            using: key!
        )
        let decryptedLastEditedDate : Data = try ChaChaPoly.open(
            ChaChaPoly.SealedBox(combined: video.lastEdited),
            using: key!
        )
        return DB_Video(
            video: decryptedVideoData,
            created: try DataConverter.dataToDate(decryptedCreatedDate),
            lastEdited: try DataConverter.dataToDate(decryptedLastEditedDate),
            id: video.id
        )
    }
    
    private func decryptChaChaPoly(document : Encrypted_DB_Document) throws -> DB_Document {
        let decryptedDocumentData : Data = try ChaChaPoly.open(
            try ChaChaPoly.SealedBox(combined: document.document),
            using: key!
        )
        let decryptedType : Data = try ChaChaPoly.open(
            try ChaChaPoly.SealedBox(combined: document.type),
            using: key!
        )
        let decryptedCreatedDate : Data = try ChaChaPoly.open(
            ChaChaPoly.SealedBox(combined: document.created),
            using: key!
        )
        let decryptedLastEditedDate : Data = try ChaChaPoly.open(
            ChaChaPoly.SealedBox(combined: document.lastEdited),
            using: key!
        )
        return DB_Document(
            document: decryptedDocumentData,
            type: DataConverter.dataToString(decryptedType),
            created: try DataConverter.dataToDate(decryptedCreatedDate),
            lastEdited: try DataConverter.dataToDate(decryptedLastEditedDate),
            id: document.id
        )
    }
}
