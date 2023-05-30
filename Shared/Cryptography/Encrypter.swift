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

/// Struct used to encypt Databases into encrypted Databases
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
            encrypter = Encrypter(encryption: .unknown)
        }
        encrypter.db = db
        return encrypter
    }
    
    /// The Encryption that is used for this Encrypter
    private let encryption : Cryptography.Encryption
    
    /// The Database that should be encrypted.
    /// This is passed with the encrypt Method,
    /// and is used by the private methods
    private var db : Database?
    
    /// This is the symmetric Key used to
    /// encrypt the Database
    private var key : SymmetricKey?
    
    private init(encryption : Cryptography.Encryption) {
        self.encryption = encryption
    }
    
    /// Encrypts the Database this Encrypter is configured for,
    /// using the getInstance method and passing your Database.
    /// Returns the encrypted Database if it could be encrypted, otherwise
    /// throws an error.
    /// See Error for more details
    internal mutating func encrypt(using password : String) throws -> EncryptedDatabase {
        key = SymmetricKey(data: password.data(using: .utf8)!)
        if encryption == .AES256 {
            return try encryptAES()
        } else if encryption == .ChaChaPoly {
            return try encryptChaChaPoly()
        } else {
            throw CryptoStatus.unknownEncryption
        }
    }
    
    /// Encrypts Databases with AES
    /// Throws an Error if something went wrong
    private func encryptAES() throws -> EncryptedDatabase {
        var encryptedFolders : [EncryptedFolder] = []
        for folder in db!.folders {
            encryptedFolders.append(try encryptAES(folder: folder))
        }
        let encryptedDatabase : EncryptedDatabase = EncryptedDatabase(
            name: db!.name,
            dbDescription: db!.dbDescription,
            folders: encryptedFolders,
            header: db!.header
        )
        return encryptedDatabase
    }
    
    /// Encryptes the passed Folder with AES and returns
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
        let encryptedName : Data = try AES.GCM.seal(
            Cryptography.stringToData(folder.name),
            using: key!
        ).combined!
        let encryptedFolder : EncryptedFolder = EncryptedFolder(
            name: encryptedName,
            folders: encryptedFolders,
            entries: encryptedEntries
        )
        return encryptedFolder
    }
    
    /// Encrypts the passed Entry with AES and returns an encrypted Entry
    private func encryptAES(entry : Entry) throws -> EncryptedEntry {
        let encryptedTitle : Data = try AES.GCM.seal(
            Cryptography.stringToData(entry.title),
            using: key!
        ).combined!
        let encryptedUsername : Data = try AES.GCM.seal(
            Cryptography.stringToData(entry.username),
            using: key!
        ).combined!
        let encryptedPassword = try AES.GCM.seal(
            Cryptography.stringToData(entry.password),
            using: key!
        ).combined!
        let encryptedURL = try AES.GCM.seal(
            Cryptography.stringToData(entry.url!.absoluteString),
            using: key!
        ).combined!
        let encryptedNotes : Data = try AES.GCM.seal(
            Cryptography.stringToData(entry.notes),
            using: key!
        ).combined!
        let encryptedEntry : EncryptedEntry = EncryptedEntry(
            title: encryptedTitle,
            username: encryptedUsername,
            password: encryptedPassword,
            url: encryptedURL,
            notes: encryptedNotes
        )
        return encryptedEntry
    }
    
    /// Encrypts Databases with ChaChaPoly
    /// Throws an Error if something went wrong
    private func encryptChaChaPoly() throws -> EncryptedDatabase {
        var encryptedFolders : [EncryptedFolder] = []
        for folder in db!.folders {
            encryptedFolders.append(try encryptChaChaPoly(folder: folder))
        }
        let encryptedDatabase : EncryptedDatabase = EncryptedDatabase(
            name: db!.name,
            dbDescription: db!.dbDescription,
            folders: encryptedFolders,
            header: db!.header
        )
        return encryptedDatabase
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
        let encryptedName : Data = try ChaChaPoly.seal(
            Cryptography.stringToData(folder.name),
            using: key!
        ).combined
        let encryptedFolder : EncryptedFolder = EncryptedFolder(
            name: encryptedName,
            folders: encryptedFolders,
            entries: encryptedEntries
        )
        return encryptedFolder
    }
    
    /// Encrypts the passed Entry with ChaChaPoly and returns an encrypted Entry
    private func encryptChaChaPoly(entry : Entry) throws -> EncryptedEntry {
        let encryptedTitle : Data = try ChaChaPoly.seal(
            Cryptography.stringToData(entry.title),
            using: key!
        ).combined
        let encryptedUsername : Data = try ChaChaPoly.seal(
            Cryptography.stringToData(entry.username),
            using: key!
        ).combined
        let encryptedPassword = try ChaChaPoly.seal(
            Cryptography.stringToData(entry.password),
            using: key!
        ).combined
        let encryptedURL = try ChaChaPoly.seal(
            Cryptography.stringToData(entry.url!.absoluteString),
            using: key!
        ).combined
        let encryptedNotes : Data = try ChaChaPoly.seal(
            Cryptography.stringToData(entry.notes),
            using: key!
        ).combined
        let encryptedEntry : EncryptedEntry = EncryptedEntry(
            title: encryptedTitle,
            username: encryptedUsername,
            password: encryptedPassword,
            url: encryptedURL,
            notes: encryptedNotes
        )
        return encryptedEntry
    }
}
