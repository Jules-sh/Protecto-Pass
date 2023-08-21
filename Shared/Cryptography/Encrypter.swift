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
        let encryptedKey : Data = try encryptAESKey()
        let encryptedDatabase : EncryptedDatabase = EncryptedDatabase(
            name: db!.name,
            description: db!.description,
            folders: encryptedFolders,
            entries: encryptedEntries,
            header: db!.header,
            key: encryptedKey
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
        let encryptedName : Data = try AES.GCM.seal(
            Cryptography.stringToData(folder.name),
            using: key!
        ).combined!
        let encryptedDescription : Data = try AES.GCM.seal(
            Cryptography.stringToData(folder.description),
            using: key!
        ).combined!
        let encryptedFolder : EncryptedFolder = EncryptedFolder(
            name: encryptedName,
            description: encryptedDescription,
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
        var encryptedEntries : [EncryptedEntry] = []
        for entry in db!.entries {
            encryptedEntries.append(try encryptChaChaPoly(entry: entry))
        }
        let encryptedKey : Data = try encryptChaChaPolyKey()
        let encryptedDatabase : EncryptedDatabase = EncryptedDatabase(
            name: db!.name,
            description: db!.description,
            folders: encryptedFolders,
            entries: encryptedEntries,
            header: db!.header,
            key: encryptedKey
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
        let encryptedName : Data = try ChaChaPoly.seal(
            Cryptography.stringToData(folder.name),
            using: key!
        ).combined
        let encryptedDescription : Data = try ChaChaPoly.seal(
            Cryptography.stringToData(folder.description),
            using: key!
        ).combined
        let encryptedFolder : EncryptedFolder = EncryptedFolder(
            name: encryptedName,
            description: encryptedDescription,
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
