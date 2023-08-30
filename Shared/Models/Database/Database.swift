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
        documents : Do,
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
internal final class Database : GeneralDatabase<Folder, Entry, [Data], DB_Image, SymmetricKey>, ObservableObject, DecryptedDataStructure {
    
    /// The Password to decrypt this Database with
    internal let password : String
    
    internal init(
        name : String,
        description : String,
        folders : [Folder],
        entries : [Entry],
        images : [DB_Image],
        iconName : String,
        documents : [Data],
        created : Date,
        lastEdited : Date,
        header : DB_Header,
        key : SymmetricKey,
        password : String
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
        self.password = password
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
internal final class EncryptedDatabase : GeneralDatabase<EncryptedFolder, EncryptedEntry, Data, Encrypted_DB_Image, Data> {
    
    override internal init(
        name: String,
        description: String,
        folders: [EncryptedFolder],
        entries: [EncryptedEntry],
        images: [Encrypted_DB_Image],
        iconName: String,
        documents: Data,
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
        self.init(
            name: DataConverter.dataToString(coreData.name!),
            description: DataConverter.dataToString(coreData.objectDescription!),
            folders: localFolders,
            entries: localEntries,
            images: localImages,
            iconName: DataConverter.dataToString(coreData.iconName!),
            documents: coreData.documents!,
            created: try DataConverter.stringToDate(DataConverter.dataToString(coreData.created!)),
            lastEdited: try DataConverter.stringToDate(DataConverter.dataToString(coreData.lastEdited!)),
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
        documents: Data(),
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
