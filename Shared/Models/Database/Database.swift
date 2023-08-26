//
//  Database.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 28.03.23.
//

import CryptoKit
import Foundation

/// The Top Level class for all databases.
/// Because the encrypted and decrypted Database have something in common,
/// this class puts these common things together
internal class GeneralDatabase<F, E, K> : ME_DataStructure<String, F, E>, Identifiable {
    
    /// The Header for this Database
    internal let header : DB_Header
    
    /// The Key that should be used to
    /// encrypt and decrypt this Database
    internal let key : K
    
    internal init(
        name : String,
        description : String,
        folders : [F],
        entries : [E],
        header : DB_Header,
        key : K
    ) {
        self.header = header
        self.key = key
        super.init(
            name: name,
            description: description,
            folders: folders,
            entries: entries
        )
    }
}

/// The Database Object that is used when the App is running
internal final class Database : GeneralDatabase<Folder, Entry, SymmetricKey>, ObservableObject {
    
    /// The Password to decrypt this Database with
    internal let password : String
    
    internal init(
        name : String,
        description : String,
        folders : [Folder],
        entries : [Entry],
        header : DB_Header,
        key : SymmetricKey,
        password : String
    ) {
        self.password = password
        super.init(
            name: name,
            description: description,
            folders: folders,
            entries: entries,
            header: header,
            key: key
        )
    }
    
    /// Attempts to encrypt the Database using the provided Password.
    /// If successful, returns the encrypted Database.
    /// Otherwise an error is thrown
    internal func encrypt() throws -> EncryptedDatabase {
        var encrypter : Encrypter = Encrypter.getInstance(for: self)
        return try encrypter.encrypt(using: password)
    }
    
    /// The Preview Database to use in Previews or Tests
    internal static let previewDB : Database = Database(
        name: "Preview Database",
        description: "This is a Preview Database used in Tests and Previews",
        folders: [],
        entries: [],
        header: DB_Header(
            encryption: .AES256,
            storageType: .CoreData,
            salt: "salt"
        ),
        key: SymmetricKey(size: .bits256),
        password: "Password"
    )
}

/// The object storing an encrypted Database
internal final class EncryptedDatabase : GeneralDatabase<EncryptedFolder, EncryptedEntry, Data> {
    
    override init(
        name: String,
        description: String,
        folders: [EncryptedFolder],
        entries: [EncryptedEntry],
        header: DB_Header,
        key: Data
    ) {
        super.init(
            name: name,
            description: description,
            folders: folders,
            entries: entries,
            header: header,
            key: key
        )
    }
    
    internal convenience init(from coreData : CD_Database) {
        var localFolders : [EncryptedFolder] = []
        for folder in coreData.folders! {
            localFolders.append(EncryptedFolder(from: folder as! CD_Folder))
        }
        var localEntries : [EncryptedEntry] = []
        for entry in coreData.entries! {
            localEntries.append(EncryptedEntry(from: entry as! CD_Entry))
        }
        self.init(
            name: String(data: coreData.name!, encoding: .utf8)!,
            description: String(data: coreData.objectDescription!, encoding: .utf8)!,
            folders: localFolders,
            entries: localEntries,
            header: DB_Header.parseString(string: coreData.header!),
            key: coreData.key!
        )
    }
    
    /// Attempts to decrypt the encrypted Database using the provided Password.
    /// If successful, returns the decrypted Database.
    /// Otherwise an error is thrown
    internal func decrypt(using password : String) throws -> Database {
        var decrypter : Decrypter = Decrypter.getInstance(for: self)
        return try decrypter.decrypt(using: password)
    }
    
    /// The Preview Database to use in Previews or Tests
    internal static let previewDB : EncryptedDatabase = EncryptedDatabase(
        name: "Preview Database",
        description: "This is an encrypted Preview Database used in Tests and Previews",
        folders: [],
        entries: [],
        header: DB_Header(
            encryption: .AES256,
            storageType: .CoreData,
            salt: "salt"
        ),
        key: Data()
    )
}
