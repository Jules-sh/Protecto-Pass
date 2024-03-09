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
internal class ME_DataStructure<DA, DE, I> : NativeType<DE, DA, I> {
    
    /// The Name of this Data Structure
    @Published internal var name : DA
    
    /// A closer description of this Object
    ///
    /// # Core Data
    /// This reflects the objectDescription Property in
    /// Core Data, because the description parameter is
    /// already taken.
    @Published internal var description : DA
    
    internal init(
        name : DA,
        description : DA,
        iconName : DA,
        created : DE,
        lastEdited : DE,
        id : I
    ) {
        self.name = name
        self.description = description
        super.init(
            iconName: iconName,
            created: created,
            lastEdited: lastEdited,
            id: id
        )
    }
}

/// Protocol which most of the Decrypted Data Structures conform to in order to use them in
/// UI Components such as Picker and a generated List
internal protocol DecryptedDataStructure : Hashable, Identifiable {}

/// Protocol which all of the encrypted Data Structures must conforms to in order
/// to store them in a File
internal protocol EncryptedDataStructure : Codable {}
