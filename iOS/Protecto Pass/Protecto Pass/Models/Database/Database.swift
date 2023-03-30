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
internal class GeneralDatabase {
    
    /// The Name of the Database
    internal let name : String
    
    /// The Description of this Databse
    internal var dbDescription : String
    
    fileprivate init(name : String, dbDescription : String) {
        self.name = name
        self.dbDescription = dbDescription
    }
}

/// The Database Object that is used when the App is running
internal class Database : GeneralDatabase {
    
    /// All the Folders in this Database
    internal let folders : [Folder]
    
    internal init(
        name : String,
        dbDescription : String = "",
        folders : [Folder]
    ) {
        self.folders = folders
        super.init(name: name, dbDescription: dbDescription)
    }
    
    /// The Preview Database to use in Previews or Tests
    internal static let previewDB : Database = Database(
        name: "Preview Database",
        dbDescription: "This is a Preview Database used in Tests and Previews",
        folders: []
    )
}

/// The object storing an encrypted Database
internal class EncryptedDatabase : GeneralDatabase {
    
    /// The Encrypted Folders being stored in this Encrypted Database
    internal let folders : [EncryptedFolder]
    
    internal init(
        name : String,
        dbDescription : String = "",
        folders: [EncryptedFolder]
    ) {
        self.folders = folders
        super.init(name: name, dbDescription: dbDescription)
    }
}
