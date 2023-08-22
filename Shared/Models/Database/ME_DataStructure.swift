//
//  ME_DataStructure.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 21.08.23.
//

import Foundation

/// ME Data Structure is short for Multiple Entity Data Structure,
/// which is used to store multiple entities in one Object.
/// Objects which have a folder-like structure or features, inherit from this class
internal class ME_DataStructure<D, F, E> {
    
    internal let name : D
    
    internal let description : D
    
    internal var folders : [F]
    
    internal var entries : [E]
    
    internal init(
        name : D,
        description : D,
        folders : [F],
        entries : [E]
    ) {
        self.name = name
        self.description = description
        self.folders = folders
        self.entries = entries
    }
}

internal class Decrypted_ME_DataStructure : ME_DataStructure<String, Folder, Entry> {}

internal class Encrypted_ME_DataStructure : ME_DataStructure<Data, EncryptedFolder, EncryptedEntry> {}

internal protocol DecryptedDataStructure : Hashable, Identifiable {}
