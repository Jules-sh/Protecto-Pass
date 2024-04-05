//
//  Encrypter.swift
//  Protecto Pass
//
//  Created by Julian Schumacher as Encoder.swift on 07.05.23.
//
//  Renamed by Julian Schumacher to Encrypter.swift on 27.05.23.
//

import CryptoKit
import Foundation

/// Struct used to encrypt Databases and their components
/// into encrypted Databases
internal struct Encrypter {
    
    /// Encrypter specified for AES 256 Bit Encryption
    private static let aes256 : Encrypter = Encrypter(encryption: .AES256)
    
    /// Encrypter specified for ChaChaPoly Encryption
    private static let chaChaPoly : Encrypter = Encrypter(encryption: .ChaChaPoly)
    
    /// Returns the correct Encrypter for the passed database
    internal static func configure(for db : Database, with password : String) -> Encrypter {
        var encrypter : Encrypter
        if db.header.encryption == .AES256 {
            encrypter = aes256
        } else if db.header.encryption == .ChaChaPoly {
            encrypter = chaChaPoly
        } else {
            encrypter = Encrypter(encryption: nil)
        }
        encrypter.password = password + db.header.salt
        encrypter.key = db.key
        encrypter.db = db
        return encrypter
    }
    
    /// The Encryption that is used for this Encrypter
    private let encryption : Cryptography.Encryption?
    
    /// The Database that should be encrypted.
    /// This is passed with the encrypt Method,
    /// and is used by the private methods
    private var db : Database?
    
    /// This is the symmetric Key used to
    /// encrypt the Database
    private var key : SymmetricKey?
    
    /// The Password used to create the Key.
    /// This is the password chosen and entered by the User
    /// combined with the Salt of this Database
    internal var password : String?
    
    private init(encryption : Cryptography.Encryption?) {
        self.encryption = encryption
    }
    
    /// Encrypts the Database this Encrypter is configured for,
    /// using the getInstance method and passing your Database.
    /// Returns the encrypted Database if it could be encrypted, otherwise
    /// throws an error.
    /// See Error for more details
    internal mutating func encrypt(using password : String) throws -> EncryptedDatabase {
        // TODO: remove method
        if encryption == .AES256 {
            return try encryptAES()
        } else if encryption == .ChaChaPoly {
            return try encryptChaChaPoly()
        } else {
            throw CryptoStatus.unknownEncryption
        }
    }
    
    // START GENERAL ENCRYPTION
    
    /// Encrypts the passed Table of Contents Item with the cryptography algorithm this Encrypter is configured for.
    /// Use the `configure` Method to configure a Encrypter
    internal func decryptToC(_ toc : ToCItem) throws -> EncryptedToCItem {
        if db!.header.encryption == .AES256 {
            return try encryptAES(toc: toc)
        } else if db!.header.encryption == .ChaChaPoly {
            return try encryptChaChaPoly(toc: toc)
        } else {
            throw CryptoStatus.unknownEncryption
        }
    }
    
    /// Encrypts the passed Table of Contents Item with the cryptography algorithm this Encrypter is configured for.
    /// Use the `configure` Method to configure a Encrypter
    internal func decryptFolder(_ folder : Folder) throws -> EncryptedFolder {
        if db!.header.encryption == .AES256 {
            return try encryptAES(folder: folder)
        } else if db!.header.encryption == .ChaChaPoly {
            return try encryptChaChaPoly(folder: folder)
        } else {
            throw CryptoStatus.unknownEncryption
        }
    }
    
    /// Encrypts the passed Table of Contents Item with the cryptography algorithm this Encrypter is configured for.
    /// Use the `configure` Method to configure a Encrypter
    internal func decryptEntry(_ entry : Entry) throws -> EncryptedEntry {
        if db!.header.encryption == .AES256 {
            return try encryptAES(entry: entry)
        } else if db!.header.encryption == .ChaChaPoly {
            return try encryptChaChaPoly(entry: entry)
        } else {
            throw CryptoStatus.unknownEncryption
        }
    }
    
    /// Encrypts the passed Table of Contents Item with the cryptography algorithm this Encrypter is configured for.
    /// Use the `configure` Method to configure a Encrypter
    internal func decryptImage(_ image : DB_Image) throws -> Encrypted_DB_Image {
        if db!.header.encryption == .AES256 {
            return try encryptAES(image: image)
        } else if db!.header.encryption == .ChaChaPoly {
            return try encryptChaChaPoly(image: image)
        } else {
            throw CryptoStatus.unknownEncryption
        }
    }
    
    /// Encrypts the passed Table of Contents Item with the cryptography algorithm this Encrypter is configured for.
    /// Use the `configure` Method to configure a Encrypter
    internal func decryptDocument(_ document : DB_Document) throws -> Encrypted_DB_Document {
        if db!.header.encryption == .AES256 {
            return try encryptAES(document: document)
        } else if db!.header.encryption == .ChaChaPoly {
            return try encryptChaChaPoly(document: document)
        } else {
            throw CryptoStatus.unknownEncryption
        }
    }
    
    // START AES ENCRYPTION
    
    /// Encrypts Databases with AES
    /// Throws an Error if something went wrong
    private func encryptAES() throws -> EncryptedDatabase {
        var encryptedContents : [EncryptedToCItem] = []
        for toc in db!.contents {
            encryptedContents.append(try encryptAES(toc: toc))
        }
        let encryptedKey : Data = try encryptAESKey()
        return EncryptedDatabase(
            name: db!.name,
            description: db!.description,
            iconName: db!.iconName,
            contents: encryptedContents,
            created: db!.created,
            lastEdited: db!.lastEdited,
            header: db!.header,
            key: encryptedKey,
            allowBiometrics: db!.allowBiometrics,
            id: db!.id
        )
    }
    
    /// Encrypts the key using AES and returns it as encrypted Data
    private func encryptAESKey() throws -> Data {
        return try AES.GCM.seal(
            key!.withUnsafeBytes {
                return Data(Array($0))
            },
            using: SymmetricKey(data: Cryptography.sha256HashBytes(password!))
        ).combined!
    }
    
    /// Encrypts a single Item of a Table of Contents using AES
    private func encryptAES(toc : ToCItem) throws -> EncryptedToCItem {
        let encryptedName : Data = try AES.GCM.seal(
            DataConverter.stringToData(toc.name),
            using: key!
        ).combined!
        let encryptedType : Data = try AES.GCM.seal(
            DataConverter.stringToData(toc.type.rawValue),
            using: key!
        ).combined!
        let encryptedID : Data = try AES.GCM.seal(
            DataConverter.stringToData(toc.id.uuidString),
            using: key!
        ).combined!
        var encryptedChildren : [EncryptedToCItem] = []
        for child in toc.children {
            encryptedChildren.append(try encryptAES(toc: child))
        }
        return EncryptedToCItem(
            name: encryptedName,
            type: encryptedType,
            id: encryptedID,
            children: encryptedChildren
        )
    }
    
    /// Encrypts the passed Folder with AES and returns
    /// an encrypted Folder
    private func encryptAES(folder : Folder) throws -> EncryptedFolder {
        let encryptedName : Data = try AES.GCM.seal(
            DataConverter.stringToData(folder.name),
            using: key!
        ).combined!
        let encryptedDescription : Data = try AES.GCM.seal(
            DataConverter.stringToData(folder.description),
            using: key!
        ).combined!
        let encryptedIconName : Data = try AES.GCM.seal(
            DataConverter.stringToData(folder.iconName),
            using: key!
        ).combined!
        let encryptedCreatedDate : Data = try AES.GCM.seal(
            DataConverter.dateToData(folder.created),
            using: key!
        ).combined!
        let encryptedLastEditedDate : Data = try AES.GCM.seal(
            DataConverter.dateToData(folder.lastEdited),
            using: key!
        ).combined!
        let encryptedID : Data = try AES.GCM.seal(
            DataConverter.stringToData(folder.id.uuidString),
            using: key!
        ).combined!
        return EncryptedFolder(
            name: encryptedName,
            description: encryptedDescription,
            iconName: encryptedIconName,
            created: encryptedCreatedDate,
            lastEdited: encryptedLastEditedDate,
            id: encryptedID
        )
    }
    
    /// Encrypts the passed Entry with AES and returns an encrypted Entry
    private func encryptAES(entry : Entry) throws -> EncryptedEntry {
        let encryptedTitle : Data = try AES.GCM.seal(
            DataConverter.stringToData(entry.title),
            using: key!
        ).combined!
        let encryptedUsername : Data = try AES.GCM.seal(
            DataConverter.stringToData(entry.username),
            using: key!
        ).combined!
        let encryptedPassword = try AES.GCM.seal(
            DataConverter.stringToData(entry.password),
            using: key!
        ).combined!
        let encryptedURL = try AES.GCM.seal(
            DataConverter.stringToData(entry.url!.absoluteString),
            using: key!
        ).combined!
        let encryptedNotes : Data = try AES.GCM.seal(
            DataConverter.stringToData(entry.notes),
            using: key!
        ).combined!
        let encryptedIconName : Data = try AES.GCM.seal(
            DataConverter.stringToData(entry.iconName),
            using: key!
        ).combined!
        let encryptedCreatedDate : Data = try AES.GCM.seal(
            DataConverter.dateToData(entry.created),
            using: key!
        ).combined!
        let encryptedLastEditedDate : Data = try AES.GCM.seal(
            DataConverter.dateToData(entry.lastEdited),
            using: key!
        ).combined!
        let encryptedID : Data = try AES.GCM.seal(
            DataConverter.stringToData(entry.id.uuidString),
            using: key!
        ).combined!
        return EncryptedEntry(
            title: encryptedTitle,
            username: encryptedUsername,
            password: encryptedPassword,
            url: encryptedURL,
            notes: encryptedNotes,
            iconName: encryptedIconName,
            created: encryptedCreatedDate,
            lastEdited: encryptedLastEditedDate,
            id: encryptedID
        )
    }
    
    /// Encrypts the passed Image with AES and returns
    /// an encrypted Image
    private func encryptAES(image : DB_Image) throws -> Encrypted_DB_Image {
        let imageData : Data = try DataConverter.imageToData(image)
        let encryptedImageData : Data = try AES.GCM.seal(
            imageData,
            using: key!
        ).combined!
        let encryptedQuality : Data = try AES.GCM.seal(
            DataConverter.doubleToData(image.quality),
            using: key!
        ).combined!
        let encryptedCreatedDate : Data = try AES.GCM.seal(
            DataConverter.dateToData(image.created),
            using: key!
        ).combined!
        let encryptedLastEditedDate : Data = try AES.GCM.seal(
            DataConverter.dateToData(image.lastEdited),
            using: key!
        ).combined!
        let encryptedID : Data = try AES.GCM.seal(
            DataConverter.stringToData(image.id.uuidString),
            using: key!
        ).combined!
        return Encrypted_DB_Image(
            image: encryptedImageData,
            quality: encryptedQuality,
            created: encryptedCreatedDate,
            lastEdited: encryptedLastEditedDate,
            id: encryptedID
        )
    }
    
    /// Encrypts the passed Document with AES and returns
    /// an encrypted Document
    private func encryptAES(document : DB_Document) throws -> Encrypted_DB_Document {
        let encryptedDocument : Data = try AES.GCM.seal(
            document.document,
            using: key!
        ).combined!
        let encryptedType : Data = try AES.GCM.seal(
            DataConverter.stringToData(document.type),
            using: key!
        ).combined!
        let encryptedCreatedDate : Data = try AES.GCM.seal(
            DataConverter.dateToData(document.created),
            using: key!
        ).combined!
        let encryptedLastEditedDate : Data = try AES.GCM.seal(
            DataConverter.dateToData(document.lastEdited),
            using: key!
        ).combined!
        let encryptedID : Data = try AES.GCM.seal(
            DataConverter.stringToData(document.id.uuidString),
            using: key!
        ).combined!
        return Encrypted_DB_Document(
            document: encryptedDocument,
            type: encryptedType,
            created: encryptedCreatedDate,
            lastEdited: encryptedLastEditedDate,
            id: encryptedID
        )
    }
    
    
    // START ChaChaPoly ENCRYPTION
    
    /// Encrypts Databases with ChaChaPoly
    /// Throws an Error if something went wrong
    private func encryptChaChaPoly() throws -> EncryptedDatabase {
        var encryptedContents : [EncryptedToCItem] = []
        for toc in db!.contents {
            encryptedContents.append(try encryptChaChaPoly(toc: toc))
        }
        let encryptedKey : Data = try encryptChaChaPolyKey()
        let encryptedDatabase : EncryptedDatabase = EncryptedDatabase(
            name: db!.name,
            description: db!.description,
            iconName: db!.iconName,
            contents: encryptedContents,
            created: db!.created,
            lastEdited: db!.lastEdited,
            header: db!.header,
            key: encryptedKey,
            allowBiometrics: db!.allowBiometrics,
            id: db!.id
        )
        return encryptedDatabase
    }
    
    /// Encrypts the key using ChaChaPoly and returns it as encrypted Data
    private func encryptChaChaPolyKey() throws -> Data {
        return try ChaChaPoly.seal(
            key!.withUnsafeBytes {
                return Data(Array($0))
            },
            using: SymmetricKey(data: Cryptography.sha256HashBytes(password!))
        ).combined
    }
    
    /// Encrypts the passed ToC Item using ChaChaPoly
    private func encryptChaChaPoly(toc : ToCItem) throws -> EncryptedToCItem {
        let encryptedName : Data = try ChaChaPoly.seal(
            DataConverter.stringToData(toc.name),
            using: key!
        ).combined
        let encryptedType : Data = try ChaChaPoly.seal(
            DataConverter.stringToData(toc.type.rawValue),
            using: key!
        ).combined
        let encryptedID : Data = try ChaChaPoly.seal(
            DataConverter.stringToData(toc.id.uuidString),
            using: key!
        ).combined
        var encryptedChildren : [EncryptedToCItem] = []
        for child in toc.children {
            encryptedChildren.append(try encryptChaChaPoly(toc: child))
        }
        return EncryptedToCItem(
            name: encryptedName,
            type: encryptedType,
            id: encryptedID,
            children: encryptedChildren
        )
    }
    
    
    /// Encryptes the passed Folder with ChaChaPoly and returns
    /// an encrypted Folder
    private func encryptChaChaPoly(folder : Folder) throws -> EncryptedFolder {
        let encryptedName : Data = try ChaChaPoly.seal(
            DataConverter.stringToData(folder.name),
            using: key!
        ).combined
        let encryptedDescription : Data = try ChaChaPoly.seal(
            DataConverter.stringToData(folder.description),
            using: key!
        ).combined
        let encryptedIconName : Data = try ChaChaPoly.seal(
            DataConverter.stringToData(folder.iconName),
            using: key!
        ).combined
        let encryptedCreatedDate : Data = try ChaChaPoly.seal(
            DataConverter.dateToData(folder.created),
            using: key!
        ).combined
        let encryptedLastEditedDate : Data = try ChaChaPoly.seal(
            DataConverter.dateToData(folder.lastEdited),
            using: key!
        ).combined
        let encryptedID : Data = try ChaChaPoly.seal(
            DataConverter.stringToData(folder.id.uuidString),
            using: key!
        ).combined
        return EncryptedFolder(
            name: encryptedName,
            description: encryptedDescription,
            iconName: encryptedIconName,
            created: encryptedCreatedDate,
            lastEdited: encryptedLastEditedDate,
            id: encryptedID
        )
    }
    
    /// Encrypts the passed Entry with ChaChaPoly and returns an encrypted Entry
    private func encryptChaChaPoly(entry : Entry) throws -> EncryptedEntry {
        let encryptedTitle : Data = try ChaChaPoly.seal(
            DataConverter.stringToData(entry.title),
            using: key!
        ).combined
        let encryptedUsername : Data = try ChaChaPoly.seal(
            DataConverter.stringToData(entry.username),
            using: key!
        ).combined
        let encryptedPassword = try ChaChaPoly.seal(
            DataConverter.stringToData(entry.password),
            using: key!
        ).combined
        let encryptedURL = try ChaChaPoly.seal(
            DataConverter.stringToData(entry.url!.absoluteString),
            using: key!
        ).combined
        let encryptedNotes : Data = try ChaChaPoly.seal(
            DataConverter.stringToData(entry.notes),
            using: key!
        ).combined
        let encryptedIconName : Data = try ChaChaPoly.seal(
            DataConverter.stringToData(entry.iconName),
            using: key!
        ).combined
        let encryptedCreatedDate : Data = try ChaChaPoly.seal(
            DataConverter.dateToData(entry.created),
            using: key!
        ).combined
        let encryptedLastEditedDate : Data = try ChaChaPoly.seal(
            DataConverter.dateToData(entry.lastEdited),
            using: key!
        ).combined
        let encryptedID : Data = try ChaChaPoly.seal(
            DataConverter.stringToData(entry.id.uuidString),
            using: key!
        ).combined
        return EncryptedEntry(
            title: encryptedTitle,
            username: encryptedUsername,
            password: encryptedPassword,
            url: encryptedURL,
            notes: encryptedNotes,
            iconName: encryptedIconName,
            created: encryptedCreatedDate,
            lastEdited: encryptedLastEditedDate,
            id: encryptedID
        )
    }
    
    /// Encrypts the passed Image with ChaChaPoly and returns
    /// an encrypted Image
    private func encryptChaChaPoly(image : DB_Image) throws -> Encrypted_DB_Image {
        let imageData : Data = try DataConverter.imageToData(image)
        let encryptedImageData : Data = try ChaChaPoly.seal(
            imageData,
            using: key!
        ).combined
        let encryptedQuality : Data = try ChaChaPoly.seal(
                DataConverter.doubleToData(image.quality),
                using: key!
            ).combined
        let encryptedCreatedDate : Data = try ChaChaPoly.seal(
            DataConverter.dateToData(image.created),
            using: key!
        ).combined
        let encryptedLastEditedDate : Data = try ChaChaPoly.seal(
            DataConverter.dateToData(image.lastEdited),
            using: key!
        ).combined
        let encryptedID : Data = try ChaChaPoly.seal(
            DataConverter.stringToData(image.id.uuidString),
            using: key!
        ).combined
        return Encrypted_DB_Image(
            image: encryptedImageData,
            quality: encryptedQuality,
            created: encryptedCreatedDate,
            lastEdited: encryptedLastEditedDate,
            id: encryptedID
        )
    }
    
    /// Encrypts the passed Document with ChaChaPoly and returns
    /// an encrypted Document
    private func encryptChaChaPoly(document : DB_Document) throws -> Encrypted_DB_Document {
        let encryptedDocument : Data = try ChaChaPoly.seal(
            document.document,
            using: key!
        ).combined
        let encryptedType : Data = try ChaChaPoly.seal(
            DataConverter.stringToData(document.type),
            using: key!
        ).combined
        let encryptedCreatedDate : Data = try ChaChaPoly.seal(
            DataConverter.dateToData(document.created),
            using: key!
        ).combined
        let encryptedLastEditedDate : Data = try ChaChaPoly.seal(
            DataConverter.dateToData(document.lastEdited),
            using: key!
        ).combined
        let encryptedID : Data = try ChaChaPoly.seal(
            DataConverter.stringToData(document.id.uuidString),
            using: key!
        ).combined
        return Encrypted_DB_Document(
            document: encryptedDocument,
            type: encryptedType,
            created: encryptedCreatedDate,
            lastEdited: encryptedLastEditedDate,
            id: encryptedID
        )
    }
}
