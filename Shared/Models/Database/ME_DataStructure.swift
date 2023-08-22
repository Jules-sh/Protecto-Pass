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

/// Subclass of ME Data Structure with types of decrypted Objects
internal class Decrypted_ME_DataStructure : ME_DataStructure<String, Folder, Entry> {}

/// Subclass of ME Data Structure with types of encrypted Objects
internal class Encrypted_ME_DataStructure : ME_DataStructure<Data, EncryptedFolder, EncryptedEntry> {}

/// Protocol which most of the Decrypted Data Structures conform to in order to use them in UI
/// Components such as Picker and a generated List
internal protocol DecryptedDataStructure : Hashable, Identifiable {}
