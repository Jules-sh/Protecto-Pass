//
//  Folder.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 28.03.23.
//

import Foundation
import UIKit

/// The Folder Object that is used when the App is running
internal final class Folder : Decrypted_ME_DataStructure, DecryptedDataStructure {
    
    /// ID to conform to Decrypted Data Structure
    internal let id: UUID = UUID()
    
    /// An static preview folder with sample data to use in Previews and Tests
    internal static let previewFolder : Folder = Folder(
        name: "Private",
        description: "This is an preview Folder only to use in previews and tests",
        folders: [],
        entries: [],
        images: [],
        iconName: "folder",
        documents: [],
        created: Date.now,
        lastEdited: Date.now
    )
    
    static func == (lhs: Folder, rhs: Folder) -> Bool {
        return lhs.name == rhs.name && lhs.description == rhs.description && lhs.folders == rhs.folders && lhs.entries == rhs.entries
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(iconName)
        hasher.combine(documents)
        hasher.combine(created)
        hasher.combine(lastEdited)
        hasher.combine(name)
        hasher.combine(description)
        hasher.combine(folders)
        hasher.combine(entries)
        hasher.combine(id)
    }
}

/// The Object holding an encrypted Folder
internal final class EncryptedFolder : Encrypted_ME_DataStructure {
    
    override internal init(
        name: Data,
        description: Data,
        folders: [EncryptedFolder],
        entries: [EncryptedEntry],
        images : [Encrypted_DB_Image],
        iconName : Data,
        documents: Data,
        created : Data,
        lastEdited : Data
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
            lastEdited: lastEdited
        )
    }
    
    internal convenience init(from coreData : CD_Folder) {
        var localFolders : [EncryptedFolder] = []
        for folder in coreData.folders! {
            localFolders.append(EncryptedFolder(from: folder as! CD_Folder))
        }
        var localEntries : [EncryptedEntry] = []
        for entry in coreData.entries! {
            localEntries.append(EncryptedEntry(from: entry as! CD_Entry))
        }
        self.init(
            name: coreData.name!,
            description: coreData.objectDescription!,
            folders: localFolders,
            entries: localEntries,
            iconName: coreData.iconName!,
            documents: coreData.documents!,
            created: coreData.created!,
            lastEdited: coreData.lastEdited!
        )
    }
}
