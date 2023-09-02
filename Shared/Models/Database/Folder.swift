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
internal final class EncryptedFolder : GeneralFolder<Data, EncryptedFolder, EncryptedEntry, Data, Encrypted_DB_Document, Encrypted_DB_Image> {
    
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
    
    internal convenience init(from json : [String : Any]) {
        var localFolders : [EncryptedFolder] = []
        let jsonFolders : [[String : Any]] = json["folders"] as! [[String : Any]]
        for jsonFolder in jsonFolders {
            localFolders.append(EncryptedFolder(from: jsonFolder))
        }
        var localEntries : [EncryptedEntry] = []
        let jsonEntries : [[String : Any]] = json["entries"] as! [[String : Any]]
        for jsonEntry in jsonEntries {
            localEntries.append(EncryptedEntry(from: jsonEntry))
        }
        var localImages : [Encrypted_DB_Image] = []
        let jsonImages : [[String : String]] = json["images"] as! [[String : String]]
        for jsonImage in jsonImages{
            localImages.append(Encrypted_DB_Image(from: jsonImage))
        }
        var localDocuments : [Encrypted_DB_Document] = []
        let jsonDocuments : [[String : String]] = json["documents"] as! [[String : String]]
        for jsonDocument in jsonDocuments {
            localDocuments.append(Encrypted_DB_Document(from: jsonDocument))
        }
        self.init(
            name: json["name"] as! Data,
            description: json["description"] as! Data,
            folders: localFolders,
            entries: localEntries,
            images: localImages,
            iconName: json["iconName"] as! Data,
            documents: localDocuments,
            created: json["created"] as! Data,
            lastEdited: json["lastEdited"] as! Data
        )
    }
    
    /// Parses this Object to a json dictionary and returns it
    internal func parseJSON() -> [String : Any] {
        var localFolders : [[String : Any]] = []
        for folder in folders {
            localFolders.append(folder.parseJSON())
        }
        var localEntries : [[String : Any]] = []
        for entry in entries {
            localEntries.append(entry.parseJSON())
        }
        var localImages : [[String : String]] = []
        for image in images {
            localImages.append(image.parseJSON())
        }
        var localDocuments : [[String : String]] = []
        for document in documents {
            localDocuments.append(document.parseJSON())
        }
        let json : [String : Any] = [
            "name" : name.base64EncodedString(),
            "description" : description.base64EncodedString(),
            "folders" : localFolders,
            "entries" : localEntries,
            "images" : localImages,
            "iconName" : iconName.base64EncodedString(),
            "documents" : localDocuments,
            "created" : created.base64EncodedString(),
            "lastEdited" : lastEdited.base64EncodedString(),
        ]
        return json
    }
}
