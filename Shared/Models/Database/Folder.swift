//
//  Folder.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 28.03.23.
//

import Foundation

/// The General Folder of which other Folder Types
/// inherit from
internal class GeneralFolder<D, F, E> {
    
    /// The name of the Folder, you could also say the title
    internal let name : D
    
    /// The description provided to this Folder
    internal let description : D
    
    /// Each folder can contain folders which again
    /// can also contain folders.
    internal var folders : [F]
    
    /// The Entries stored in this Folder
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

/// The Folder Object that is used when the App is running
internal final class Folder : GeneralFolder<String, Folder, Entry>, Identifiable {
    
    internal let id: UUID = UUID()
}

/// The Object holding an encrypted Folder
internal final class EncryptedFolder : GeneralFolder<Data, EncryptedFolder, EncryptedEntry> {
    
    internal init(from coreData : CD_Folder) {
        super.init(
            name: coreData.name!,
            description: coreData.folderDescription!,
            folders: [],
            entries: []
        )
        var folders : [EncryptedFolder] = []
        for folder in coreData.folders! {
            folders.append(EncryptedFolder(from: folder as! CD_Folder))
        }
        self.folders.append(contentsOf: folders)
        var entries : [EncryptedEntry] = []
        for entry in coreData.entries! {
            entries.append(EncryptedEntry(from: entry as! CD_Entry))
        }
        self.entries.append(contentsOf: entries)
    }
}
