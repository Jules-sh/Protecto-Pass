//
//  Database.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 28.03.23.
//

import CryptoKit
import Foundation
import UIKit

/// The Top Level class for all databases.
/// Because the encrypted and decrypted Database have something in common,
/// this class puts these common things together
internal class GeneralDatabase<K, F, E> : ME_DataStructure<String, Date, F, E>, Identifiable {
    
    /// The Header for this Database
    internal let header : DB_Header
    
    /// The Key that should be used to
    /// encrypt and decrypt this Database
    internal let key : K

    /// Whether or not biometrics are allow to decrypt and unlock this Database
    internal let allowBiometrics : Bool
    
    internal init(
        name : String,
        description : String,
        folders : [F],
        entries : [E],
        iconName : String,
        created : Date,
        lastEdited : Date,
        header : DB_Header,
        key : K,
        allowBiometrics : Bool,
        id: UUID
    ) {
        self.header = header
        self.key = key
        self.allowBiometrics = allowBiometrics
        super.init(
            name: name,
            description: description,
            folders: folders,
            entries: entries,
            iconName: iconName,
            created: created,
            lastEdited : lastEdited,
            id: id
        )
    }
}

/// The Database Object that is used when the App is running
internal final class Database : GeneralDatabase<SymmetricKey, Folder, Entry>, DecryptedDataStructure {
    
    /// The Password to decrypt this Database with
    internal let password : String
    
    internal init(
        name : String,
        description : String,
        folders : [Folder],
        entries : [Entry],
        iconName : String,
        created : Date,
        lastEdited : Date,
        header : DB_Header,
        key : SymmetricKey,
        password : String,
        allowBiometrics : Bool,
        id: UUID
    ) {
        self.password = password
        super.init(
            name: name,
            description: description,
            folders: folders,
            entries: entries,
            iconName: iconName,
            created: created,
            lastEdited: lastEdited,
            header: header,
            key: key,
            allowBiometrics: allowBiometrics,
            id: id
        )
    }
    
    /// The Preview Database to use in Previews or Tests
    internal static let previewDB : Database = Database(
        name: "Preview Database",
        description: "This is a Preview Database used in Tests and Previews",
        folders: [],
        entries: [],
        iconName: "externaldrive",
        created: Date.now,
        lastEdited: Date.now,
        header: DB_Header(
            encryption: .AES256,
            storageType: .CoreData,
            salt: "salt"
        ),
        key: SymmetricKey(size: .bits256),
        password: "Password",
        allowBiometrics: true,
        id: UUID()
    )
    
    static func == (lhs: Database, rhs: Database) -> Bool {
        return lhs.name == rhs.name &&
        lhs.description == rhs.description &&
        lhs.iconName == rhs.iconName &&
        lhs.folders == rhs.folders &&
        lhs.entries == rhs.entries &&
        lhs.created == rhs.created &&
        lhs.lastEdited == rhs.lastEdited &&
        lhs.header.parseHeader() == rhs.header.parseHeader() &&
        lhs.key == rhs.key &&
        lhs.password == rhs.password &&
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(header.parseHeader())
        hasher.combine(name)
        hasher.combine(description)
        hasher.combine(folders)
        hasher.combine(entries)
        hasher.combine(iconName)
        hasher.combine(id)
    }
}

/// The object storing an encrypted Database
internal final class EncryptedDatabase : GeneralDatabase<Data, EncryptedFolder, EncryptedEntry>, EncryptedDataStructure {
    
    override internal init(
        name: String,
        description: String,
        folders: [EncryptedFolder],
        entries: [EncryptedEntry],
        iconName: String,
        created : Date,
        lastEdited : Date,
        header: DB_Header,
        key: Data,
        allowBiometrics : Bool,
        id: UUID
    ) {
        super.init(
            name: name,
            description: description,
            folders: folders,
            entries: entries,
            iconName: iconName,
            created: created,
            lastEdited: lastEdited,
            header: header,
            key: key,
            allowBiometrics: allowBiometrics,
            id: id
        )
    }
    
    private enum DatabaseCodingKeys: CodingKey {
        case name
        case description
        case iconName
        case folders
        case entries
        case created
        case lastEdited
        case header
        case key
        case allowBiometrics
        case id
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: DatabaseCodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(description, forKey: .description)
        try container.encode(folders, forKey: .folders)
        try container.encode(entries, forKey: .entries)
        try container.encode(iconName, forKey: .iconName)
        try container.encode(created, forKey: .created)
        try container.encode(lastEdited, forKey: .lastEdited)
        try container.encode(header, forKey: .header)
        try container.encode(key, forKey: .key)
        try container.encode(allowBiometrics, forKey: .allowBiometrics)
        try container.encode(id, forKey: .id)
    }
    
    internal convenience init(from decoder: Decoder) throws {
        let container : KeyedDecodingContainer = try decoder.container(keyedBy: DatabaseCodingKeys.self)
        self.init(
            name: try container.decode(String.self, forKey: .name),
            description: try container.decode(String.self, forKey: .description),
            folders: try container.decode([EncryptedFolder].self, forKey: .folders),
            entries: try container.decode([EncryptedEntry].self, forKey: .entries),
            iconName: try container.decode(String.self, forKey: .iconName),
            created: try container.decode(Date.self, forKey: .created),
            lastEdited: try container.decode(Date.self, forKey: .lastEdited),
            header: try container.decode(DB_Header.self, forKey: .header),
            key:try container.decode(Data.self, forKey: .key),
            allowBiometrics: try container.decode(Bool.self, forKey: .allowBiometrics),
            id: try container.decode(UUID.self, forKey: .id)
        )
    }
    
    internal convenience init(from coreData : CD_Database) throws {
        var localFolders : [EncryptedFolder] = []
        for folder in coreData.folders! {
            
        }
        var localEntries : [EncryptedEntry] = []
        for entry in coreData.entries! {
        }
        self.init(
            name: DataConverter.dataToString(coreData.name!),
            description: DataConverter.dataToString(coreData.objectDescription),
            folders: localFolders,
            entries: localEntries,
            iconName: DataConverter.dataToString(coreData.iconName!),
            created: try DataConverter.dataToDate(coreData.created!),
            lastEdited: try DataConverter.dataToDate(coreData.lastEdited!),
            header: try DB_Header.parseString(string: coreData.header!),
            key: coreData.key!,
            allowBiometrics: coreData.allowBiometrics,
            id: coreData.uuid!
        )
    }
    
    /// The Preview Database to use in Previews or Tests
    internal static let previewDB : EncryptedDatabase = EncryptedDatabase(
        name: "Preview Database",
        description: "This is an encrypted Preview Database used in Tests and Previews",
        folders: [],
        entries: [],
        iconName: "externaldrive",
        created: Date.now,
        lastEdited: Date.now,
        header: DB_Header(
            encryption: .AES256,
            storageType: .CoreData,
            salt: "salt"
        ),
        key: Data(),
        allowBiometrics: true,
        id: UUID()
    )
}
