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
    internal static func getInstance(for db : Database) -> Encrypter {
        var encrypter : Encrypter
        if db.header.encryption == .AES256 {
            encrypter = aes256
        } else if db.header.encryption == .ChaChaPoly {
            encrypter = chaChaPoly
        } else {
            encrypter = Encrypter(encryption: nil)
        }
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
        self.password = password + db!.header.salt
        key = db!.key
        if encryption == .AES256 {
            return try encryptAES()
        } else if encryption == .ChaChaPoly {
            return try encryptChaChaPoly()
        } else {
            throw CryptoStatus.unknownEncryption
        }
    }
    
    // START AES ENCRYPTION
    
    /// Encrypts Databases with AES
    /// Throws an Error if something went wrong
    private func encryptAES() throws -> EncryptedDatabase {
        var encryptedFolders : [EncryptedFolder] = []
        for folder in db!.folders {
            encryptedFolders.append(try encryptAES(folder: folder))
        }
        var encryptedEntries : [EncryptedEntry] = []
        for entry in db!.entries {
            encryptedEntries.append(try encryptAES(entry: entry))
        }
        var encryptedImages : [Encrypted_DB_Image] = []
        for image in db!.images {
            encryptedImages.append(try encryptAES(image: image))
        }
        var encryptedDocuments : [Encrypted_DB_Document] = []
        for doc in db!.documents {
            encryptedDocuments.append(try encryptAES(document: doc))
        }
        let encryptedKey : Data = try encryptAESKey()
        let encryptedDatabase : EncryptedDatabase = EncryptedDatabase(
            name: db!.name,
            description: db!.description,
            folders: encryptedFolders,
            entries: encryptedEntries,
            images: encryptedImages,
            iconName: db!.iconName,
            documents: encryptedDocuments,
            created: db!.created,
            lastEdited: db!.lastEdited,
            header: db!.header,
            key: encryptedKey,
            allowBiometrics: db!.allowBiometrics,
            id: db!.id
        )
        return encryptedDatabase
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
    
    /// Encrypts the passed Folder with AES and returns
    /// an encrypted Folder
    private func encryptAES(folder : Folder) throws -> EncryptedFolder {
        var encryptedFolders : [EncryptedFolder] = []
        for folder in folder.folders {
            encryptedFolders.append(try encryptAES(folder: folder))
        }
        var encryptedEntries : [EncryptedEntry] = []
        for entry in folder.entries {
            encryptedEntries.append(try encryptAES(entry: entry))
        }
        var encryptedImages : [Encrypted_DB_Image] = []
        for image in folder.images {
            encryptedImages.append(try encryptAES(image: image))
        }
        var encryptedDocuments : [Encrypted_DB_Document] = []
        for doc in folder.documents {
            encryptedDocuments.append(try encryptAES(document: doc))
        }
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
        let encryptedFolder : EncryptedFolder = EncryptedFolder(
            name: encryptedName,
            description: encryptedDescription,
            folders: encryptedFolders,
            entries: encryptedEntries,
            images: encryptedImages,
            iconName: encryptedIconName,
            documents: encryptedDocuments,
            created: encryptedCreatedDate,
            lastEdited: encryptedLastEditedDate
        )
        return encryptedFolder
    }
    
    /// Encrypts the passed Entry with AES and returns an encrypted Entry
    private func encryptAES(entry : Entry) throws -> EncryptedEntry {
        var encryptedDocuments : [Encrypted_DB_Document] = []
        for doc in entry.documents {
            encryptedDocuments.append(try encryptAES(document: doc))
        }
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
        let encryptedEntry : EncryptedEntry = EncryptedEntry(
            title: encryptedTitle,
            username: encryptedUsername,
            password: encryptedPassword,
            url: encryptedURL,
            notes: encryptedNotes,
            iconName: encryptedIconName,
            documents: encryptedDocuments,
            created: encryptedCreatedDate,
            lastEdited: encryptedLastEditedDate
        )
        return encryptedEntry
    }
    
    /// Encrypts the passed Image with AES and returns
    /// an encrypted Image
    private func encryptAES(image : DB_Image) throws -> Encrypted_DB_Image {
        let imageData : Data = try DataConverter.imageToData(image)
        let encryptedImageData : Data = try AES.GCM.seal(
            imageData,
            using: key!
        ).combined!
        let encryptedType : Data = try AES.GCM.seal(
            DataConverter.stringToData(image.type.rawValue),
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
        return Encrypted_DB_Image(
            image: encryptedImageData,
            type: encryptedType,
            quality: encryptedQuality,
            created: encryptedCreatedDate,
            lastEdited: encryptedLastEditedDate
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
        return Encrypted_DB_Document(
            document: encryptedDocument,
            type: encryptedType,
            created: encryptedCreatedDate,
            lastEdited: encryptedLastEditedDate
        )
    }
    
    
    // START ChaChaPoly ENCRYPTION
    
    /// Encrypts Databases with ChaChaPoly
    /// Throws an Error if something went wrong
    private func encryptChaChaPoly() throws -> EncryptedDatabase {
        var encryptedFolders : [EncryptedFolder] = []
        for folder in db!.folders {
            encryptedFolders.append(try encryptChaChaPoly(folder: folder))
        }
        var encryptedEntries : [EncryptedEntry] = []
        for entry in db!.entries {
            encryptedEntries.append(try encryptChaChaPoly(entry: entry))
        }
        var encryptedImages : [Encrypted_DB_Image] = []
        for image in db!.images {
            encryptedImages.append(try encryptChaChaPoly(image: image))
        }
        var encryptedDocuments : [Encrypted_DB_Document] = []
        for doc in db!.documents {
            encryptedDocuments.append(try encryptChaChaPoly(document: doc))
        }
        let encryptedKey : Data = try encryptChaChaPolyKey()
        let encryptedDatabase : EncryptedDatabase = EncryptedDatabase(
            name: db!.name,
            description: db!.description,
            folders: encryptedFolders,
            entries: encryptedEntries,
            images: encryptedImages,
            iconName: db!.iconName,
            documents: encryptedDocuments,
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
    
    
    /// Encryptes the passed Folder with ChaChaPoly and returns
    /// an encrypted Folder
    private func encryptChaChaPoly(folder : Folder) throws -> EncryptedFolder {
        var encryptedFolders : [EncryptedFolder] = []
        for folder in folder.folders {
            encryptedFolders.append(try encryptChaChaPoly(folder: folder))
        }
        var encryptedEntries : [EncryptedEntry] = []
        for entry in folder.entries {
            encryptedEntries.append(try encryptChaChaPoly(entry: entry))
        }
        var encryptedImages : [Encrypted_DB_Image] = []
        for image in folder.images {
            encryptedImages.append(try encryptChaChaPoly(image: image))
        }
        var encryptedDocuments : [Encrypted_DB_Document] = []
        for doc in db!.documents {
            encryptedDocuments.append(try encryptChaChaPoly(document: doc))
        }
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
        let encryptedFolder : EncryptedFolder = EncryptedFolder(
            name: encryptedName,
            description: encryptedDescription,
            folders: encryptedFolders,
            entries: encryptedEntries,
            images: encryptedImages,
            iconName: encryptedIconName,
            documents: encryptedDocuments,
            created: encryptedCreatedDate,
            lastEdited: encryptedLastEditedDate
        )
        return encryptedFolder
    }
    
    /// Encrypts the passed Entry with ChaChaPoly and returns an encrypted Entry
    private func encryptChaChaPoly(entry : Entry) throws -> EncryptedEntry {
        var encryptedDocuments : [Encrypted_DB_Document] = []
        for doc in db!.documents {
            encryptedDocuments.append(try encryptChaChaPoly(document: doc))
        }
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
        let encryptedEntry : EncryptedEntry = EncryptedEntry(
            title: encryptedTitle,
            username: encryptedUsername,
            password: encryptedPassword,
            url: encryptedURL,
            notes: encryptedNotes,
            iconName: encryptedIconName,
            documents: encryptedDocuments,
            created: encryptedCreatedDate,
            lastEdited: encryptedLastEditedDate
        )
        return encryptedEntry
    }
    
    /// Encrypts the passed Image with ChaChaPoly and returns
    /// an encrypted Image
    private func encryptChaChaPoly(image : DB_Image) throws -> Encrypted_DB_Image {
        let imageData : Data = try DataConverter.imageToData(image)
        let encryptedImageData : Data = try ChaChaPoly.seal(
            imageData,
            using: key!
        ).combined
        let encryptedType : Data = try ChaChaPoly.seal(
            DataConverter.stringToData(image.type.rawValue),
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
        return Encrypted_DB_Image(
            image: encryptedImageData,
            type: encryptedType,
            quality: encryptedQuality,
            created: encryptedCreatedDate,
            lastEdited: encryptedLastEditedDate
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
        return Encrypted_DB_Document(
            document: encryptedDocument,
            type: encryptedType,
            created: encryptedCreatedDate,
            lastEdited: encryptedLastEditedDate
        )
    }
}
