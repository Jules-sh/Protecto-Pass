//
//  KeychainManager.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 25.08.23.
//

import Foundation

/// Struct to store a Database in the Keychain
internal struct KeychainManager : DatabaseCache {
        
    internal static var allDatabases: [EncryptedDatabase] = []
    
    private static var db : EncryptedDatabase?

    internal static func accessCache(id: UUID) throws -> EncryptedDatabase {
        if databaseExists(id: id) {
            return allDatabases.first(where: { $0.id == id })!
        } else {
            throw DatabaseDoesNotExistError()
        }
    }
    
    static func update(id: UUID, with new: EncryptedDatabase) -> Void {
        allDatabases.removeAll(where: { $0.id == id })
        allDatabases.append(new)
    }
    
    static func databaseExists(id: UUID) -> Bool {
        return allDatabases.contains(where: { $0.id == id })
    }
    
    internal static func storeDatabase(_ db : EncryptedDatabase) -> Void {
        self.db = db
        for folder in db.folders {
            storeFolder(folder)
        }
        for entry in db.entries {
            storeEntry(entry)
        }
        for image in db.images {
            storeImage(image)
        }
        for document in db.documents {
            storeDocument(document)
        }
        let nameQuery : [CFString : Any] = [
            kSecClass :  kSecClassGenericPassword,
            kSecAttrService : db.name,
            kSecAttrLabel : "name",
            kSecAttrAccount : "database",
            kSecAttrDescription : "/"
        ]
        SecItemAdd(nameQuery as CFDictionary, nil)
        let descriptionQuery : [CFString : Any] = [
            kSecClass : kSecClassGenericPassword,
            kSecAttrService : db.name,
            kSecAttrLabel : "description",
            kSecAttrAccount : "database",
            kSecAttrDescription : "/"
        ]
        SecItemAdd(descriptionQuery as CFDictionary, nil)
        
        self.db = nil
    }
    
    private static func storeFolder(_ folder : EncryptedFolder) -> Void {
        for folder in folder.folders {
            storeFolder(folder)
        }
        for entry in folder.entries {
            storeEntry(entry)
        }
        for image in folder.images {
            storeImage(image)
        }
        for document in folder.documents {
            storeDocument(document)
        }
    }
    
    private static func storeEntry(_ entry : EncryptedEntry) -> Void {
        for document in entry.documents {
            storeDocument(document)
        }
    }
    
    private static func storeImage(_ image : Encrypted_DB_Image) -> Void {
    }
    
    private static func storeDocument(_ document : Encrypted_DB_Document) -> Void {
    }
    
    internal static func load() -> [EncryptedDatabase] {
        // TODO: implement
        return []
    }
}
