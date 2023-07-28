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
internal class GeneralDatabase<F, E, K> : Identifiable {
    
    /// The Name of the Database
    internal let name : String
    
    /// The Description of this Database
    internal let dbDescription : String
    
    /// The Header for this Database
    internal let header : DB_Header
    
    /// All the Folders in this Database
    internal let folders : [F]
    
    /// All the entries in the "root" directory
    internal let entries : [E]
    
    /// The Key that should be used to
    /// encrypt and decrypt this Database
    internal let key : K
    
    internal init(name : String, dbDescription : String, header : DB_Header, folders : [F], entries : [E], key : K) {
        self.name = name
        self.dbDescription = dbDescription
        self.header = header
        self.folders = folders
        self.entries = entries
        self.key = key
    }
    
    internal init(from coreData : CD_Database) {
        // All of these conditions have to be matched, otherwise this
        // init constructor is called to create something else than an
        // encrypted Database
        assert(F.self is EncryptedFolder.Type)
        assert(E.self is EncryptedEntry.Type)
        assert(K.self is Data.Type)
        name = coreData.name!
        dbDescription = coreData.dbDescription!
        header = DB_Header.parseString(string: coreData.header!)
        var localFolders : [EncryptedFolder] = []
        for folder in coreData.folders! {
            localFolders.append(EncryptedFolder(from: folder as! CD_Folder))
        }
        folders = localFolders as! [F]
        var localEntries : [EncryptedEntry] = []
        for entry in coreData.entries! {
            localEntries.append(EncryptedEntry(from: entry as! CD_Entry))
        }
        entries = localEntries as! [E]
        key = coreData.key! as! K
    }
}

/// The Database Object that is used when the App is running
internal final class Database : GeneralDatabase<Folder, Entry, SymmetricKey>, ObservableObject {
    
    /// The Password to decrypt this Database with
    internal let password : String
    
    internal init(
        name : String,
        dbDescription : String,
        header : DB_Header,
        folders : [Folder],
        entries : [Entry],
        key : SymmetricKey,
        password : String
    ) {
        self.password = password
        super.init(name: name, dbDescription: dbDescription, header: header, folders: folders, entries: entries, key: key)
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
        dbDescription: "This is a Preview Database used in Tests and Previews",
        header: DB_Header(
            encryption: .AES256,
            storageType: .CoreData,
            salt: "salt"
        ),
        folders: [],
        entries: [],
        key: SymmetricKey(size: .bits256),
        password: "Password"
    )
}

/// The object storing an encrypted Database
internal final class EncryptedDatabase : GeneralDatabase<EncryptedFolder, EncryptedEntry, Data> {
    
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
        dbDescription: "This is an encrypted Preview Database used in Tests and Previews",
        header: DB_Header(
            encryption: .AES256,
            storageType: .CoreData,
            salt: "salt"
        ),
        folders: [],
        entries: [],
        key: Data()
    )
}
