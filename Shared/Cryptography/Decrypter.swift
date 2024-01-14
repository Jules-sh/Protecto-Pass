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
    internal static func getInstance(for db : EncryptedDatabase) -> Decrypter {
        var decrypter : Decrypter
        if db.header.encryption == .AES256 {
            decrypter = aes256
        } else if db.header.encryption == .ChaChaPoly {
            decrypter = chaChaPoly
        } else {
            decrypter = Decrypter(encryption: nil)
        }
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
        self.password = password + db!.header.salt
        userPassword = password
        if encryption == .AES256 {
            return try decryptAES()
        } else if encryption == .ChaChaPoly {
            return try decryptChaChaPoly()
        } else {
            throw CryptoStatus.unknownEncryption
        }
    }
    
    /// Decrypts AES encrypted Databases
    /// /// Throws an Error if something went wrong
    private mutating func decryptAES() throws -> Database {
        key = try decryptAESKey()
        var decryptedFolders : [Folder] = []
        for folder in db!.folders {
            decryptedFolders.append(try decryptAES(folder: folder))
        }
        var decryptedEntries : [Entry] = []
        for entry in db!.entries {
            decryptedEntries.append(try decryptAES(entry: entry))
        }
        var decryptedImages : [DB_Image] = []
        for image in db!.images {
            decryptedImages.append(try decryptAES(image: image))
        }
        var decryptedDocuments : [DB_Document] = []
        for doc in db!.documents {
            decryptedDocuments.append(try decryptAES(document: doc))
        }
        let decryptedDatabase : Database = Database(
            name: db!.name,
            description: db!.description,
            folders: decryptedFolders,
            entries: decryptedEntries,
            images: decryptedImages,
            iconName: db!.iconName,
            documents: decryptedDocuments,
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
        var decryptedFolders : [Folder] = []
        for folder in folder.folders {
            decryptedFolders.append(try decryptAES(folder: folder))
        }
        var decryptedEntries : [Entry] = []
        for entry in folder.entries {
            decryptedEntries.append(try decryptAES(entry: entry))
        }
        var decryptedImages : [DB_Image] = []
        for image in folder.images {
            decryptedImages.append(try decryptAES(image: image))
        }
        var decryptedDocuments : [DB_Document] = []
        for doc in folder.documents {
            decryptedDocuments.append(try decryptAES(document: doc))
        }
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
        let decryptedFolder : Folder = Folder(
            name: DataConverter.dataToString(decryptedName),
            description: DataConverter.dataToString(decryptedDescription),
            folders: decryptedFolders,
            entries: decryptedEntries,
            images: decryptedImages,
            iconName: DataConverter.dataToString(decryptedIconName),
            documents: decryptedDocuments,
            created: try DataConverter.dataToDate(decryptedCreatedDate),
            lastEdited: try DataConverter.dataToDate(decryptedLastEditedDate)
        )
        return decryptedFolder
    }
    
    /// Decrypts the passed Entry using AES and returns and decrypted Entry
    private func decryptAES(entry : EncryptedEntry) throws -> Entry {
        var decryptedDocuments : [DB_Document] = []
        for doc in entry.documents {
            decryptedDocuments.append(try decryptAES(document: doc))
        }
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
        let decryptedEntry : Entry = Entry(
            title: DataConverter.dataToString(decryptedTitle),
            username: DataConverter.dataToString(decryptedUsername),
            password: DataConverter.dataToString(decryptedPassword),
            url: URL(string: DataConverter.dataToString(decryptedURL)),
            notes: DataConverter.dataToString(decryptedNotes),
            iconName: DataConverter.dataToString(decryptedIconName),
            documents: decryptedDocuments,
            created: try DataConverter.dataToDate(decryptedCreatedDate),
            lastEdited: try DataConverter.dataToDate(decryptedLastEditedDate)
        )
        return decryptedEntry
    }
    
    /// Decrypts the passed Image using AES and returns a decrypted Image
    private func decryptAES(image : Encrypted_DB_Image) throws -> DB_Image {
        let decryptedImageData : Data = try AES.GCM.open(
            try AES.GCM.SealedBox(combined: image.image),
            using: key!
        )
        let decryptedTypeData : Data = try AES.GCM.open(
            try AES.GCM.SealedBox(combined: image.type),
            using: key!
        )
        let decryptedTypeString : String = DataConverter.dataToString(decryptedTypeData)
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
        let decryptedImageObj : DB_Image = DB_Image(
            image: UIImage(data: decryptedImageData)!,
            type: ImageType(rawValue: decryptedTypeString)!,
            quality: decryptedQuality,
            created: try DataConverter.dataToDate(decryptedCreatedDate),
            lastEdited: try DataConverter.dataToDate(decryptedLastEditedDate)
        )
        return decryptedImageObj
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
        let decryptedDocument : DB_Document = DB_Document(
            document: decryptedDocumentData,
            type: DataConverter.dataToString(decryptedType),
            created: try DataConverter.dataToDate(decryptedCreatedDate),
            lastEdited: try DataConverter.dataToDate(decryptedLastEditedDate)
        )
        return decryptedDocument
    }
    
    
    // START ChaChaPoly DECRYPTION
    
    /// Decrypts ChaChaPoly Encrypted Databases
    /// Throws an Error if something went wrong
    private mutating func decryptChaChaPoly() throws -> Database {
        key = try decryptChaChaPolyKey()
        var decryptedFolders : [Folder] = []
        for folder in db!.folders {
            decryptedFolders.append(try decryptChaChaPoly(folder: folder))
        }
        var decryptedEntries : [Entry] = []
        for entry in db!.entries {
            decryptedEntries.append(try decryptChaChaPoly(entry: entry))
        }
        var decryptedImages : [DB_Image] = []
        for image in db!.images {
            decryptedImages.append(try decryptChaChaPoly(image: image))
        }
        var decryptedDocuments : [DB_Document] = []
        for doc in db!.documents {
            decryptedDocuments.append(try decryptChaChaPoly(document: doc))
        }
        let decryptedDatabase : Database = Database(
            name: db!.name,
            description: db!.description,
            folders: decryptedFolders,
            entries: decryptedEntries,
            images: decryptedImages,
            iconName: db!.iconName,
            documents: decryptedDocuments,
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
    
    private func decryptChaChaPoly(folder : EncryptedFolder) throws -> Folder {
        var decryptedFolders : [Folder] = []
        for folder in folder.folders {
            decryptedFolders.append(try decryptChaChaPoly(folder: folder))
        }
        var decryptedEntries : [Entry] = []
        for entry in folder.entries {
            decryptedEntries.append(try decryptChaChaPoly(entry: entry))
        }
        var decryptedImages : [DB_Image] = []
        for image in folder.images {
            decryptedImages.append(try decryptChaChaPoly(image: image))
        }
        var decryptedDocuments : [DB_Document] = []
        for doc in folder.documents {
            decryptedDocuments.append(try decryptChaChaPoly(document: doc))
        }
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
        let decryptedFolder : Folder = Folder(
            name: DataConverter.dataToString(decryptedName),
            description: DataConverter.dataToString(decryptedDescription),
            folders: decryptedFolders,
            entries: decryptedEntries,
            images: decryptedImages,
            iconName: DataConverter.dataToString(decryptedIconName),
            documents: decryptedDocuments,
            created: try DataConverter.dataToDate(decryptedCreatedDate),
            lastEdited: try DataConverter.dataToDate(decryptedLastEditedDate)
        )
        return decryptedFolder
    }
    
    private func decryptChaChaPoly(entry : EncryptedEntry) throws -> Entry {
        var decryptedDocuments : [DB_Document] = []
        for doc in entry.documents {
            decryptedDocuments.append(try decryptChaChaPoly(document: doc))
        }
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
        let decryptedEntry : Entry = Entry(
            title: DataConverter.dataToString(decryptedTitle),
            username: DataConverter.dataToString(decryptedUsername),
            password: DataConverter.dataToString(decryptedPassword),
            url: URL(string: DataConverter.dataToString(decryptedURL)),
            notes: DataConverter.dataToString(decryptedNotes),
            iconName: DataConverter.dataToString(decryptedIconName),
            documents: decryptedDocuments,
            created: try DataConverter.dataToDate(decryptedCreatedDate),
            lastEdited: try DataConverter.dataToDate(decryptedLastEditedDate)
        )
        return decryptedEntry
    }
    
    private func decryptChaChaPoly(image : Encrypted_DB_Image) throws -> DB_Image {
        let decryptedImageData : Data = try ChaChaPoly.open(
            try ChaChaPoly.SealedBox(combined: image.image),
            using: key!
        )
        let decryptedTypeData : Data = try ChaChaPoly.open(
            try ChaChaPoly.SealedBox(combined: image.type),
            using: key!
        )
        let decryptedTypeString : String = DataConverter.dataToString(decryptedTypeData)
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
        let decryptedImageObj : DB_Image = DB_Image(
            image: UIImage(data: decryptedImageData)!,
            type: ImageType(rawValue: decryptedTypeString)!,
            quality: decryptedQuality,
            created: try DataConverter.dataToDate(decryptedCreatedDate),
            lastEdited: try DataConverter.dataToDate(decryptedLastEditedDate)
        )
        return decryptedImageObj
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
        let decryptedDocument : DB_Document = DB_Document(
            document: decryptedDocumentData,
            type: DataConverter.dataToString(decryptedType),
            created: try DataConverter.dataToDate(decryptedCreatedDate),
            lastEdited: try DataConverter.dataToDate(decryptedLastEditedDate)
        )
        return decryptedDocument
    }
}
