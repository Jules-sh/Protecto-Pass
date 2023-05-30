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

internal enum DecryptionError : Error {
    case errUnlocking
    case unknownEncryption
}

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
            decrypter = Decrypter(encryption: .unknown)
        }
        decrypter.db = db
        return decrypter
    }
    
    /// The Encryption that is used for this Decrypter
    private let encryption : Cryptography.Encryption
    
    /// The Database that should be decrypted.
    /// This is passed with the decrypt Method,
    /// and is used by the private methods
    private var db : EncryptedDatabase?
    
    /// This is the symmetric Key used to
    /// decrypt the Database
    private var key : SymmetricKey?
    
    /// Private init, to prevent creating this Object.
    /// Only use getInstance with the database you want to decrypt
    private init(encryption : Cryptography.Encryption) {
        self.encryption = encryption
    }
    
    /// Decrypts the Database this Decrypter is configured for,
    /// using the getInstance method and passing your Database.
    /// Returns the decrypted Database if it could be decrypted, otherwise
    /// throws an error.
    /// See Error for more details
    internal mutating func decrypt(using password : String) throws -> Database {
        key = SymmetricKey(data: password.data(using: .utf8)!)
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
    private func decryptAES() throws -> Database {
        var decryptedFolders : [Folder] = []
        for folder in db!.folders {
            decryptedFolders.append(try decryptAES(folder: folder))
        }
        let decryptedDatabase : Database = Database(
            name: db!.name,
            dbDescription: db!.dbDescription,
            folders: decryptedFolders,
            header: db!.header
        )
        return decryptedDatabase
    }
    
    private func decryptAES(folder : EncryptedFolder) throws -> Folder {
        var decryptedFolders : [Folder] = []
        for folder in folder.folders {
            decryptedFolders.append(try decryptAES(folder: folder))
        }
        var decryptedEntries : [Entry] = []
        for entry in folder.entries {
            decryptedEntries.append(try decryptAES(entry: entry))
        }
        let decryptedName : Data = try AES.GCM.open(
            try AES.GCM.SealedBox(combined: folder.name),
            using: key!
        )
        let decryptedFolder : Folder = Folder(
            name: String(data: decryptedName, encoding: .utf8)!,
            folders: decryptedFolders,
            entries: decryptedEntries
        )
        return decryptedFolder
    }
    
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
        let decryptedEntry : Entry = Entry(
            title: String(data: decryptedTitle, encoding: .utf8)!,
            username: String(data: decryptedUsername, encoding: .utf8)!,
            password: String(data: decryptedPassword, encoding: .utf8)!,
            url: URL(string: String(data: decryptedURL, encoding: .utf8)!)!,
            notes: String(data: decryptedNotes, encoding: .utf8)!
        )
        return decryptedEntry
    }
    
    /// Decrypts ChaChaPoly Encrypted Databases
    /// Throws an Error if something went wrong
    private func decryptChaChaPoly() throws -> Database {
        var decryptedFolders : [Folder] = []
        for folder in db!.folders {
            decryptedFolders.append(try decryptChaChaPoly(folder: folder))
        }
        let decryptedDatabase : Database = Database(
            name: db!.name,
            dbDescription: db!.dbDescription,
            folders: decryptedFolders,
            header: db!.header
        )
        return decryptedDatabase
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
        let decryptedName : Data = try ChaChaPoly.open(
            try ChaChaPoly.SealedBox(combined: folder.name),
            using: key!
        )
        let decryptedFolder : Folder = Folder(
            name: String(data: decryptedName, encoding: .utf8)!,
            folders: decryptedFolders,
            entries: decryptedEntries
        )
        return decryptedFolder
    }
    
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
        let decryptedEntry : Entry = Entry(
            title: String(data: decryptedTitle, encoding: .utf8)!,
            username: String(data: decryptedUsername, encoding: .utf8)!,
            password: String(data: decryptedPassword, encoding: .utf8)!,
            url: URL(string: String(data: decryptedURL, encoding: .utf8)!)!,
            notes: String(data: decryptedNotes, encoding: .utf8)!
        )
        return decryptedEntry
    }
}
