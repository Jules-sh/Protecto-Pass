//
//  Folder.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 28.03.23.
//

import Foundation
import UIKit

internal class GeneralFolder<D, F, E, De, Do, I> : ME_DataStructure<D, F, E, De, Do, I> {}

/// The Folder Object that is used when the App is running
internal final class Folder : GeneralFolder<String, Folder, Entry, Date, DB_Document, DB_Image>, DecryptedDataStructure {
    
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
        return lhs.name == rhs.name && lhs.description == rhs.description && lhs.folders == rhs.folders && lhs.entries == rhs.entries && lhs.id == rhs.id
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
internal final class EncryptedFolder : GeneralFolder<Data, EncryptedFolder, EncryptedEntry, Data, Encrypted_DB_Document, Encrypted_DB_Image>, EncryptedDataStructure {
    
    override internal init(
        name: Data,
        description: Data,
        folders: [EncryptedFolder],
        entries: [EncryptedEntry],
        images : [Encrypted_DB_Image],
        iconName : Data,
        documents: [Encrypted_DB_Document],
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
    
    private enum FolderCodingKeys: CodingKey {
        case name
        case description
        case folders
        case entries
        case images
        case iconName
        case documents
        case created
        case lastEdited
    }
    
    internal func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: FolderCodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(description, forKey: .description)
        try container.encode(folders, forKey: .folders)
        try container.encode(entries, forKey: .entries)
        try container.encode(images, forKey: .images)
        try container.encode(iconName, forKey: .iconName)
        try container.encode(documents, forKey: .documents)
        try container.encode(created, forKey: .created)
        try container.encode(lastEdited, forKey: .lastEdited)
    }
    
    internal  convenience init(from decoder: Decoder) throws {
        let container : KeyedDecodingContainer = try decoder.container(keyedBy: FolderCodingKeys.self)
        self.init(
            name: try container.decode(Data.self, forKey: .name),
            description: try container.decode(Data.self, forKey: .description),
            folders: try container.decode([EncryptedFolder].self, forKey: .folders),
            entries: try container.decode([EncryptedEntry].self, forKey: .entries),
            images: try container.decode([Encrypted_DB_Image].self, forKey: .images),
            iconName: try container.decode(Data.self, forKey: .iconName),
            documents: try container.decode([Encrypted_DB_Document].self, forKey: .documents),
            created: try container.decode(Data.self, forKey: .created),
            lastEdited: try container.decode(Data.self, forKey: .lastEdited)
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
        var localImages : [Encrypted_DB_Image] = []
        for image in coreData.images! {
            localImages.append(Encrypted_DB_Image(from: image as! CD_Image))
        }
        var localDocuments : [Encrypted_DB_Document] = []
        for doc in coreData.documents! {
            localDocuments.append(Encrypted_DB_Document(from: doc as! CD_Document))
        }
        self.init(
            name: coreData.name!,
            description: coreData.objectDescription!,
            folders: localFolders,
            entries: localEntries,
            images: localImages,
            iconName: coreData.iconName!,
            documents: localDocuments,
            created: coreData.created!,
            lastEdited: coreData.lastEdited!
        )
    }
}
