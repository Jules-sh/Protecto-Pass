//
//  Folder.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 28.03.23.
//

import Foundation
import UIKit

internal class GeneralFolder<DA, DE, T> : ME_DataStructure<DA, DE, T> {}

/// The Folder Object that is used when the App is running
internal final class Folder : GeneralFolder<String, Date, TableOfContents>, DecryptedDataStructure {
    
    /// ID to conform to Decrypted Data Structure
    internal let id: UUID = UUID()
    
    /// An static preview folder with sample data to use in Previews and Tests
    internal static let previewFolder : Folder = Folder(
        name: "Private",
        description: "This is an preview Folder only to use in previews and tests",
        iconName: "folder",
        contents: TableOfContents(contents: []),
        created: Date.now,
        lastEdited: Date.now
    )
    
    static func == (lhs: Folder, rhs: Folder) -> Bool {
        return lhs.name == rhs.name && lhs.description == rhs.description && lhs.id == rhs.id && lhs.contents == rhs.contents
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(iconName)
        hasher.combine(created)
        hasher.combine(lastEdited)
        hasher.combine(contents)
        hasher.combine(name)
        hasher.combine(description)
        hasher.combine(id)
    }
}

/// The Object holding an encrypted Folder
internal final class EncryptedFolder : GeneralFolder<Data, Data, EncryptedTableOfContents>, EncryptedDataStructure {
    
    override internal init(
        name: Data,
        description: Data,
        iconName : Data,
        contents: EncryptedTableOfContents,
        created : Data,
        lastEdited : Data
    ) {
        super.init(
            name: name,
            description: description,
            iconName: iconName,
            contents: contents,
            created: created,
            lastEdited: lastEdited
        )
    }
    
    private enum FolderCodingKeys: CodingKey {
        case name
        case description
        case contents
        case iconName
        case created
        case lastEdited
    }
    
    internal func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: FolderCodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(description, forKey: .description)
        try container.encode(contents, forKey: .contents)
        try container.encode(iconName, forKey: .iconName)
        try container.encode(created, forKey: .created)
        try container.encode(lastEdited, forKey: .lastEdited)
    }
    
    internal  convenience init(from decoder: Decoder) throws {
        let container : KeyedDecodingContainer = try decoder.container(keyedBy: FolderCodingKeys.self)
        self.init(
            name: try container.decode(Data.self, forKey: .name),
            description: try container.decode(Data.self, forKey: .description),
            iconName: try container.decode(Data.self, forKey: .iconName),
            contents: try container.decode(EncryptedTableOfContents.self, forKey: .contents),
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
            iconName: coreData.iconName!,
            contents: coreData.tableOfContents,
            created: coreData.created!,
            lastEdited: coreData.lastEdited!
        )
    }
}
