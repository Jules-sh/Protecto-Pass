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
internal class GeneralDatabase<F, E, Do, I, K> : ME_DataStructure<String, F, E, Date, Do, I>, Identifiable {
    
    /// ID to conform to identifiable
    internal let id : UUID = UUID()
    
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
        images : [I],
        iconName : String,
        documents : [Do],
        created : Date,
        lastEdited : Date,
        header : DB_Header,
        key : K
    ) {
        self.header = header
        self.key = key
        super.init(
            name: name,
            description: description,
            folders: folders,
            entries: entries,
            images: images,
            iconName: iconName,
            documents: documents,
            created: created,
            lastEdited : lastEdited
        )
    }
}

/// The Database Object that is used when the App is running
internal final class Database : GeneralDatabase<Folder, Entry, DB_Document, DB_Image, SymmetricKey>, ObservableObject, DecryptedDataStructure {
    
    /// The Password to decrypt this Database with
    internal let password : String
    
    internal init(
        name : String,
        description : String,
        folders : [Folder],
        entries : [Entry],
        images : [DB_Image],
        iconName : String,
        documents : [DB_Document],
        created : Date,
        lastEdited : Date,
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
            images: images,
            iconName: iconName,
            documents: documents,
            created: created,
            lastEdited: lastEdited,
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
        images: [],
        iconName: "externaldrive",
        documents: [],
        created: Date.now,
        lastEdited: Date.now,
        header: DB_Header(
            encryption: .AES256,
            storageType: .CoreData,
            salt: "salt"
        ),
        key: SymmetricKey(size: .bits256),
        password: "Password"
    )
    
    static func == (lhs: Database, rhs: Database) -> Bool {
        return lhs.name == rhs.name &&
        lhs.description == rhs.description &&
        lhs.folders == rhs.folders &&
        lhs.entries == rhs.entries &&
        lhs.images == rhs.images &&
        lhs.iconName == rhs.iconName &&
        lhs.documents == rhs.documents &&
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
        hasher.combine(id)
    }
}

/// The object storing an encrypted Database
internal final class EncryptedDatabase : GeneralDatabase<EncryptedFolder, EncryptedEntry, Encrypted_DB_Document, Encrypted_DB_Image, Data>, EncryptedDataStructure {
    
    override internal init(
        name: String,
        description: String,
        folders: [EncryptedFolder],
        entries: [EncryptedEntry],
        images: [Encrypted_DB_Image],
        iconName: String,
        documents: [Encrypted_DB_Document],
        created : Date,
        lastEdited : Date,
        header: DB_Header,
        key: Data
    ) {
        super.init(
            name: name,
            description: description,
            folders: folders,
            entries: entries,
            images: images,
            iconName: iconName,
            documents: documents,
            created: created,
            lastEdited: lastEdited,
            header: header,
            key: key
        )
    }
    
    private enum DatabaseCodingKeys: CodingKey {
        case name
        case description
        case folders
        case entries
        case images
        case iconName
        case documents
        case created
        case lastEdited
        case header
        case key
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: DatabaseCodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(description, forKey: .description)
        try container.encode(folders, forKey: .folders)
        try container.encode(entries, forKey: .entries)
        try container.encode(images, forKey: .images)
        try container.encode(iconName, forKey: .iconName)
        try container.encode(documents, forKey: .documents)
        try container.encode(created, forKey: .created)
        try container.encode(lastEdited, forKey: .lastEdited)
        try container.encode(header, forKey: .header)
        try container.encode(key, forKey: .key)
    }
    
    internal convenience init(from decoder: Decoder) throws {
        let container : KeyedDecodingContainer = try decoder.container(keyedBy: DatabaseCodingKeys.self)
        self.init(
            name: try container.decode(String.self, forKey: .name),
            description: try container.decode(String.self, forKey: .description),
            folders: try container.decode([EncryptedFolder].self, forKey: .folders),
            entries: try container.decode([EncryptedEntry].self, forKey: .entries),
            images: try container.decode([Encrypted_DB_Image].self, forKey: .images),
            iconName: try container.decode(String.self, forKey: .iconName),
            documents: try container.decode([Encrypted_DB_Document].self, forKey: .documents),
            created: try container.decode(Date.self, forKey: .created),
            lastEdited: try container.decode(Date.self, forKey: .lastEdited),
            header: try container.decode(DB_Header.self, forKey: .header),
            key:try container.decode(Data.self, forKey: .key)
        )
    }
    
    internal convenience init(from coreData : CD_Database) throws {
        var localFolders : [EncryptedFolder] = []
        for folder in coreData.folders! {
            localFolders.append(EncryptedFolder(from: folder as! CD_Folder))
        }
        var localEntries : [EncryptedEntry] = []
        for entry in coreData.entries! {
            localEntries.append(EncryptedEntry(from: entry as! CD_Entry))
        }
        var localImages : [Encrypted_DB_Image] = []
        for image in coreData.images! {
            localImages.append(Encrypted_DB_Image(from: image as! CD_Image))
        }
        var localDocuments : [Encrypted_DB_Document] = []
        for doc in coreData.documents! {
            localDocuments.append(Encrypted_DB_Document(from: doc as! CD_Document))
        }
        self.init(
            name: DataConverter.dataToString(coreData.name!),
            description: DataConverter.dataToString(coreData.objectDescription!),
            folders: localFolders,
            entries: localEntries,
            images: localImages,
            iconName: DataConverter.dataToString(coreData.iconName!),
            documents: localDocuments,
            created: try DataConverter.dataToDate(coreData.created!),
            lastEdited: try DataConverter.dataToDate(coreData.lastEdited!),
            header: try DB_Header.parseString(string: coreData.header!),
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
        images: [],
        iconName: "externaldrive",
        documents: [],
        created: Date.now,
        lastEdited: Date.now,
        header: DB_Header(
            encryption: .AES256,
            storageType: .CoreData,
            salt: "salt"
        ),
        key: Data()
    )
}
