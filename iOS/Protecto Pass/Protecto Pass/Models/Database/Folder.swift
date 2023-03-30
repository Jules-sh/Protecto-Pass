//
//  Folder.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 28.03.23.
//

import Foundation

/// The Folder Object that is used when the App is running
internal struct Folder {
    
    /// The name of the Folder, you could also say the title
    internal let name : String
    
    /// Each folder can contain folders which again
    /// can also contain folders.
    internal let folders : [Folder]
    
    /// The Entries stored in this Folder
    internal let entries : [Entry]
}

/// The Object holding an encrypted Folder
internal struct EncryptedFolder {
    
    /// The name of this Folder encrypted
    /// and securlely stores as bytes
    internal let name : [Data]
    
    /// The Folders inside this Folders, each encrypted
    /// to an encrypted Folder again
    internal let folders : [EncryptedFolder]
    
    /// The Entries in this Folder encrypted to
    /// Encrypted Entries
    internal let entries : [EncryptedEntry]
}
