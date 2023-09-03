//
//  Entry.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 28.03.23.
//

import Foundation
import SwiftUI

internal class GeneralEntry<D, U, I, De, Do> : NativeType<De, I, Do> {
    
    /// The Title of this Entry
    internal let title : D
    
    /// The Username connected to this Entry
    internal let username : D
    
    /// The Password stored with this Entry
    internal let password : D
    
    /// The URL this Entry is connected to
    internal let url : U
    
    /// Some notes storing whatever
    /// the User wants to add to this Entry
    internal let notes : D
    
    internal init(
        title: D,
        username: D,
        password: D,
        url: U,
        notes: D,
        iconName : I,
        documents : [Do],
        created : De,
        lastEdited : De
    ) {
        self.title = title
        self.username = username
        self.password = password
        self.url = url
        self.notes = notes
        super.init(
            iconName: iconName,
            documents: documents,
            created: created,
            lastEdited: lastEdited
        )
    }
}

/// The Struct representing an Entry
/// while this App is running
internal final class Entry : GeneralEntry<String, URL?, String, Date, DB_Document>, DecryptedDataStructure {
    
    /// ID to conform to Identifiable
    internal let id: UUID = UUID()
    
    internal static let previewEntry : Entry = Entry(
        title: "Password Safe",
        username: "user",
        password: "testPassword",
        url: nil,
        notes: "This is a preview Entry, only to use in previews and tests",
        iconName: "folder",
        documents: [],
        created: Date.now,
        lastEdited: Date.now
    )
    
    static func == (lhs: Entry, rhs: Entry) -> Bool {
        return lhs.title == rhs.title &&
        lhs.username == rhs.username &&
        lhs.password == rhs.password &&
        lhs.url == rhs.url &&
        lhs.notes == rhs.notes &&
        lhs.created == rhs.created &&
        lhs.lastEdited == rhs.lastEdited &&
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(iconName)
        hasher.combine(documents)
        hasher.combine(created)
        hasher.combine(lastEdited)
        hasher.combine(title)
        hasher.combine(username)
        hasher.combine(password)
        hasher.combine(url)
        hasher.combine(notes)
    }
}

/// The Encrypted Entry storing all the
/// Data of an Entry secure and encrypted
internal final class EncryptedEntry : GeneralEntry<Data, Data, Data, Data, Encrypted_DB_Document>, EncryptedDataStructure {
    
    override internal init(
        title : Data,
        username : Data,
        password : Data,
        url : Data,
        notes : Data,
        iconName : Data,
        documents : [Encrypted_DB_Document],
        created : Data,
        lastEdited : Data
    ) {
        super.init(
            title: title,
            username: username,
            password: password,
            url: url,
            notes: notes,
            iconName: iconName,
            documents: documents,
            created: created,
            lastEdited: lastEdited
        )
    }
    
    private enum EntryCodingKeys: CodingKey {
        case title
        case username
        case password
        case url
        case notes
        case iconName
        case documents
        case created
        case lastEdited
    }
    
    internal func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: EntryCodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(username, forKey: .username)
        try container.encode(password, forKey: .password)
        try container.encode(url, forKey: .url)
        try container.encode(notes, forKey: .notes)
        try container.encode(iconName, forKey: .iconName)
        try container.encode(documents, forKey: .documents)
        try container.encode(created, forKey: .created)
        try container.encode(lastEdited, forKey: .lastEdited)
    }
    
    internal convenience init(from decoder: Decoder) throws {
        let container : KeyedDecodingContainer = try decoder.container(keyedBy: EntryCodingKeys.self)
        self.init(
            title: try container.decode(Data.self, forKey: .title),
            username: try container.decode(Data.self, forKey: .username),
            password: try container.decode(Data.self, forKey: .password),
            url: try container.decode(Data.self, forKey: .url),
            notes: try container.decode(Data.self, forKey: .notes),
            iconName: try container.decode(Data.self, forKey: .iconName),
            documents: try container.decode([Encrypted_DB_Document].self, forKey: .documents),
            created: try container.decode(Data.self, forKey: .created),
            lastEdited: try container.decode(Data.self, forKey: .lastEdited)
        )
    }
    
    internal init(from coreData : CD_Entry) {
        var localDocuments : [Encrypted_DB_Document] = []
        for doc in coreData.documents! {
            localDocuments.append(Encrypted_DB_Document(from: doc as! CD_Document))
        }
        super.init(
            title: coreData.title!,
            username: coreData.username!,
            password: coreData.password!,
            url: coreData.url!,
            notes: coreData.notes!,
            iconName: coreData.iconName!,
            documents: localDocuments,
            created: coreData.created!,
            lastEdited: coreData.lastEdited!
        )
    }
}
