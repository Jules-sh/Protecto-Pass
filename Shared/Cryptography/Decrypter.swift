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

/// The possible errors when decrypting a Database
internal enum DecryptionError : Error {
    
    /// There's been an error unlocking the Database
    case errUnlocking
    
    /// The encryption that was used
    /// for this Database is unknown
    case unknownEncryption
}

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
    
    /// Decrypts the Database this Decrypter is configured for,
    /// using the getInstance method and passing your Database.
    /// Returns the decrypted Database if it could be decrypted, otherwise
    /// throws an error.
    /// See Error for more details
    internal mutating func decrypt(using password : String) throws -> Database {
        // TODO: remove method
        if encryption == .AES256 {
            return try decryptAES()
        } else if encryption == .ChaChaPoly {
            return try decryptChaChaPoly()
        } else {
            throw CryptoStatus.unknownEncryption
        }
    }
    
    // START GENERAL DECRYPTION
    
    /// Decrypts the passed Table of Contents Item with the cryptography algorithm this Decrypter is configured for.
    /// Use the `configure` Method to configure a Decrypted
    internal func decryptToC(_ toc : EncryptedToCItem) throws -> ToCItem {
        if db!.header.encryption == .AES256 {
            return try decryptAES(toc: toc)
        } else if db!.header.encryption == .ChaChaPoly {
            return try decryptChaChaPoly(toc: toc)
        } else {
            throw DecryptionError.unknownEncryption
        }
    }
    
    /// Decrypts the passed Folder with the cryptography algorithm this Decrypter is configured for.
    /// Use the `configure` Method to configure a Decrypted
    internal func decryptFolder(_ folder : EncryptedFolder) throws -> Folder {
        if db!.header.encryption == .AES256 {
            return try decryptAES(folder: folder)
        } else if db!.header.encryption == .ChaChaPoly {
            return try decryptChaChaPoly(folder: folder)
        } else {
            throw DecryptionError.unknownEncryption
        }
    }
    
    /// Decrypts the passed Entry with the cryptography algorithm this Decrypter is configured for.
    /// Use the `configure` Method to configure a Decrypted
    internal func decryptEntry(_ entry : EncryptedEntry) throws -> Entry {
        if db!.header.encryption == .AES256 {
            return try decryptAES(entry: entry)
        } else if db!.header.encryption == .ChaChaPoly {
            return try decryptChaChaPoly(entry: entry)
        } else {
            throw DecryptionError.unknownEncryption
        }
    }
    
    /// Decrypts the passed Image with the cryptography algorithm this Decrypter is configured for.
    /// Use the `configure` Method to configure a Decrypted
    internal func decryptImage(_ image : Encrypted_DB_Image) throws -> DB_Image {
        if db!.header.encryption == .AES256 {
            return try decryptAES(image: image)
        } else if db!.header.encryption == .ChaChaPoly {
            return try decryptChaChaPoly(image: image)
        } else {
            throw DecryptionError.unknownEncryption
        }
    }
    
    /// Decrypts the passed Document with the cryptography algorithm this Decrypter is configured for.
    /// Use the `configure` Method to configure a Decrypted
    internal func decryptDocument(_ document : Encrypted_DB_Document) throws -> DB_Document {
        if db!.header.encryption == .AES256 {
            return try decryptAES(document: document)
        } else if db!.header.encryption == .ChaChaPoly {
            return try decryptChaChaPoly(document: document)
        } else {
            throw DecryptionError.unknownEncryption
        }
    }
    
    // START AES DECRYPTION
    
    /// Decrypts AES encrypted Databases
    private mutating func decryptAES() throws -> Database {
        key = try decryptAESKey()
        var decryptedContents : [ToCItem] = []
        for toc in db!.contents {
            decryptedContents.append(try decryptAES(toc: toc))
        }
        return Database(
            name: db!.name,
            description: db!.description,
            iconName: db!.iconName,
            contents: decryptedContents,
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
    
    /// Decrypts a single Item of a Table of Contents using AES
    private func decryptAES(toc : EncryptedToCItem) throws -> ToCItem {
        let decryptedName : Data = try AES.GCM.open(
            try AES.GCM.SealedBox(combined: toc.name),
            using: key!
        )
        let decryptedTypeData : Data = try AES.GCM.open(
            AES.GCM.SealedBox(combined: toc.type),
            using: key!
        )
        let decryptedTypeRaw : String = DataConverter.dataToString(decryptedTypeData)
        let decryptedidData : Data = try AES.GCM.open(
            try AES.GCM.SealedBox(combined: toc.id),
            using: key!
        )
        let decryptedidString : String = DataConverter.dataToString(decryptedidData)
        var decryptedChildren : [ToCItem] = []
        for child in toc.children {
            decryptedChildren.append(try decryptAES(toc: child))
        }
        return ToCItem(
            name: DataConverter.dataToString(decryptedName),
            type: ContentType(rawValue: decryptedTypeRaw)!,
            id: UUID(uuidString: decryptedidString)!,
            children: decryptedChildren
        )
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
        let decryptedidData : Data = try AES.GCM.open(
            try AES.GCM.SealedBox(combined: folder.id),
            using: key!
        )
        let decryptedidString : String = DataConverter.dataToString(decryptedidData)
        return Folder(
            name: DataConverter.dataToString(decryptedName),
            description: DataConverter.dataToString(decryptedDescription),
            iconName: DataConverter.dataToString(decryptedIconName),
            created: try DataConverter.dataToDate(decryptedCreatedDate),
            lastEdited: try DataConverter.dataToDate(decryptedLastEditedDate),
            id: UUID(uuidString: decryptedidString)!
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
        let decryptedidData : Data = try AES.GCM.open(
            try AES.GCM.SealedBox(combined: entry.id),
            using: key!
        )
        let decryptedidString : String = DataConverter.dataToString(decryptedidData)
        return Entry(
            title: DataConverter.dataToString(decryptedTitle),
            username: DataConverter.dataToString(decryptedUsername),
            password: DataConverter.dataToString(decryptedPassword),
            url: URL(string: DataConverter.dataToString(decryptedURL)),
            notes: DataConverter.dataToString(decryptedNotes),
            iconName: DataConverter.dataToString(decryptedIconName),
            created: try DataConverter.dataToDate(decryptedCreatedDate),
            lastEdited: try DataConverter.dataToDate(decryptedLastEditedDate),
            id: UUID(uuidString: decryptedidString)!
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
        let decryptedidData : Data = try AES.GCM.open(
            try AES.GCM.SealedBox(combined: image.id),
            using: key!
        )
        let decryptedidString : String = DataConverter.dataToString(decryptedidData)
        return DB_Image(
            image: UIImage(data: decryptedImageData)!,
            quality: decryptedQuality,
            created: try DataConverter.dataToDate(decryptedCreatedDate),
            lastEdited: try DataConverter.dataToDate(decryptedLastEditedDate),
            id: UUID(uuidString: decryptedidString)!
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
        let decryptedidData : Data = try AES.GCM.open(
            try AES.GCM.SealedBox(combined: document.id),
            using: key!
        )
        let decryptedidString : String = DataConverter.dataToString(decryptedidData)
        return DB_Document(
            document: decryptedDocumentData,
            type: DataConverter.dataToString(decryptedType),
            created: try DataConverter.dataToDate(decryptedCreatedDate),
            lastEdited: try DataConverter.dataToDate(decryptedLastEditedDate),
            id: UUID(uuidString: decryptedidString)!
        )
    }
    
    
    // START ChaChaPoly DECRYPTION
    
    /// Decrypts ChaChaPoly Encrypted Databases
    /// Throws an Error if something went wrong
    private mutating func decryptChaChaPoly() throws -> Database {
        var decryptedContents : [ToCItem] = []
        for toc in db!.contents {
            decryptedContents.append(try decryptChaChaPoly(toc: toc))
        }
        key = try decryptChaChaPolyKey()
        let decryptedDatabase : Database = Database(
            name: db!.name,
            description: db!.description,
            iconName: db!.iconName,
            contents: decryptedContents,
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
    
    /// Decrypts the passed ToC Item using ChaChaPoly
    private func decryptChaChaPoly(toc : EncryptedToCItem) throws -> ToCItem {
        let decryptedName : Data = try ChaChaPoly.open(
            ChaChaPoly.SealedBox(combined: toc.name),
            using: key!
        )
        let decryptedTypeData : Data = try ChaChaPoly.open(
            ChaChaPoly.SealedBox(combined: toc.type),
            using: key!
        )
        let decryptedTypeString : String = DataConverter.dataToString(decryptedTypeData)
        let decryptedIDData : Data = try ChaChaPoly.open(
            ChaChaPoly.SealedBox(combined: toc.id),
            using: key!
        )
        let decryptedIDString : String = DataConverter.dataToString(decryptedIDData)
        var decryptedChildren : [ToCItem] = []
        for child in toc.children {
            decryptedChildren.append(try decryptChaChaPoly(toc: child))
        }
        return ToCItem(
            name: DataConverter.dataToString(decryptedName),
            type: ContentType(rawValue: decryptedTypeString)!,
            id: UUID(uuidString: decryptedIDString)!,
            children: decryptedChildren
        )
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
        let decryptedIDData : Data = try ChaChaPoly.open(
            ChaChaPoly.SealedBox(combined: folder.id),
            using: key!
        )
        let decryptedIDString : String = DataConverter.dataToString(decryptedIDData)
        return Folder(
            name: DataConverter.dataToString(decryptedName),
            description: DataConverter.dataToString(decryptedDescription),
            iconName: DataConverter.dataToString(decryptedIconName),
            created: try DataConverter.dataToDate(decryptedCreatedDate),
            lastEdited: try DataConverter.dataToDate(decryptedLastEditedDate),
            id: UUID(uuidString: decryptedIDString)!
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
        let decryptedIDData : Data = try ChaChaPoly.open(
            ChaChaPoly.SealedBox(combined: entry.id),
            using: key!
        )
        let decryptedIDString : String = DataConverter.dataToString(decryptedIDData)
        return Entry(
            title: DataConverter.dataToString(decryptedTitle),
            username: DataConverter.dataToString(decryptedUsername),
            password: DataConverter.dataToString(decryptedPassword),
            url: URL(string: DataConverter.dataToString(decryptedURL)),
            notes: DataConverter.dataToString(decryptedNotes),
            iconName: DataConverter.dataToString(decryptedIconName),
            created: try DataConverter.dataToDate(decryptedCreatedDate),
            lastEdited: try DataConverter.dataToDate(decryptedLastEditedDate),
            id: UUID(uuidString: decryptedIDString)!
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
        let decryptedIDData : Data = try ChaChaPoly.open(
            ChaChaPoly.SealedBox(combined: image.id),
            using: key!
        )
        let decryptedIDString : String = DataConverter.dataToString(decryptedIDData)
        return DB_Image(
            image: UIImage(data: decryptedImageData)!,
            quality: decryptedQuality,
            created: try DataConverter.dataToDate(decryptedCreatedDate),
            lastEdited: try DataConverter.dataToDate(decryptedLastEditedDate),
            id: UUID(uuidString: decryptedIDString)!
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
        let decryptedIDData : Data = try ChaChaPoly.open(
            ChaChaPoly.SealedBox(combined: document.id),
            using: key!
        )
        let decryptedIDString : String = DataConverter.dataToString(decryptedIDData)
        return DB_Document(
            document: decryptedDocumentData,
            type: DataConverter.dataToString(decryptedType),
            created: try DataConverter.dataToDate(decryptedCreatedDate),
            lastEdited: try DataConverter.dataToDate(decryptedLastEditedDate),
            id: UUID(uuidString: decryptedIDString)!
        )
    }
}
