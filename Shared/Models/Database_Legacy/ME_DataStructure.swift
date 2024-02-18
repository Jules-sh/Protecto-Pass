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
internal class ME_DataStructure<D, F, E, De, Do, I> : NativeType<De, D, Do> {
    
    /// The Name of this Data Structure
    @Published internal var name : D
    
    /// A closer description of this Object
    ///
    /// # Core Data
    /// This reflects the objectDescription Property in
    /// Core Data, because the description parameter is
    /// already taken.
    @Published internal var description : D
    
    /// All the folders stored in this Multiple Entity
    /// Data Structure
    @Published internal var folders : [F]
    
    /// All the entries stored within this Structure
    @Published internal var entries : [E]
    
    /// The Images stored in this Folder
    @Published internal var images : [I]
    
    internal init(
        name : D,
        description : D,
        folders : [F],
        entries : [E],
        images : [I],
        iconName : D,
        documents : [Do],
        created : De,
        lastEdited : De
    ) {
        self.name = name
        self.description = description
        self.folders = folders
        self.entries = entries
        self.images = images
        super.init(
            iconName: iconName,
            documents: documents,
            created: created,
            lastEdited: lastEdited
        )
    }
}

/// Protocol which most of the Decrypted Data Structures conform to in order to use them in
/// UI Components such as Picker and a generated List
internal protocol DecryptedDataStructure : Hashable, Identifiable {}

/// Protocol which all of the encrypted Data Structures must conforms to in order
/// to store them in a File
internal protocol EncryptedDataStructure : Codable {}
