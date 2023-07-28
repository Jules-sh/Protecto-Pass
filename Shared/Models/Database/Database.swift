//
//  Database.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 28.03.23.
//

import Foundation

/// The Top Level class for all databases.
/// Because the encrypted and decrypted Database have something in common,
/// this class puts these common things together
internal class GeneralDatabase<F, E> : Identifiable {
    
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
    
    internal convenience init(
        name : String,
        dbDescription : String,
        encryption : Cryptography.Encryption,
        storageType : DB_Header.StorageType,
        salt : String,
        folders: [F],
        entries : [E]
    ){
        self.init(
            name: name,
            dbDescription: dbDescription,
            header: DB_Header(
                encryption: encryption,
                storageType: storageType,
                salt: salt
            ),
            folders: folders,
            entries: entries
        )
    }
    
    internal init(name : String, dbDescription : String, header : DB_Header, folders : [F], entries : [E]) {
        self.name = name
        self.dbDescription = dbDescription
        self.header = header
        self.folders = folders
        self.entries = entries
    }
    
    internal init(from coreData : CD_Database) {
        assert(F.self is EncryptedFolder.Type)
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
    }
}

/// The Database Object that is used when the App is running
internal final class Database : GeneralDatabase<Folder, Entry>, ObservableObject {
    
    /// The Password to decrypt this Database with
    internal let password : String
    
    internal init(
        name : String,
        dbDescription : String,
        header : DB_Header,
        folders : [Folder],
        entries : [Entry],
        password : String
    ) {
        self.password = password
        super.init(name: name, dbDescription: dbDescription, header: header, folders: folders, entries: entries)
    }
    
    internal convenience init(
        name: String,
        dbDescription: String,
        encryption : Cryptography.Encryption,
        storageType : DB_Header.StorageType,
        salt : String,
        folders : [Folder],
        entries : [Entry],
        password : String
    ) {
        self.init(
            name: name,
            dbDescription: dbDescription,
            header: DB_Header(
                encryption: encryption,
                storageType: storageType,
                salt: salt
            ),
            folders: folders,
            entries: entries,
            password: password
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
        dbDescription: "This is a Preview Database used in Tests and Previews",
        header: DB_Header(
            encryption: .AES256,
            storageType: .CoreData,
            salt: "salt"
        ),
        folders: [],
        entries: [],
        password: "Password"
    )
}

/// The object storing an encrypted Database
internal final class EncryptedDatabase : GeneralDatabase<EncryptedFolder, EncryptedEntry> {
    
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
        entries: []
    )
}
