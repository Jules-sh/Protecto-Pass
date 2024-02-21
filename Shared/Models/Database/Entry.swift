//
//  Entry.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 28.03.23.
//

import Foundation
import SwiftUI

internal class GeneralEntry<DA, U, DE, T> : NativeType<DE, DA, T> {
    
    /// The Title of this Entry
    internal let title : DA
    
    /// The Username connected to this Entry
    internal let username : DA
    
    /// The Password stored with this Entry
    internal let password : DA
    
    /// The URL this Entry is connected to
    internal let url : U
    
    /// Some notes storing whatever
    /// the User wants to add to this Entry
    internal let notes : DA
    
    internal init(
        title: DA,
        username: DA,
        password: DA,
        url: U,
        notes: DA,
        iconName : DA,
        contents : [T],
        created : DE,
        lastEdited : DE
    ) {
        self.title = title
        self.username = username
        self.password = password
        self.url = url
        self.notes = notes
        super.init(
            iconName: iconName,
            contents: contents,
            created: created,
            lastEdited: lastEdited
        )
    }
}

/// The Struct representing an Entry
/// while this App is running
internal final class Entry : GeneralEntry<String, URL?, Date, ToCItem>, DecryptedDataStructure {
    
    /// ID to conform to Identifiable
    internal let id: UUID = UUID()
    
    internal static let previewEntry : Entry = Entry(
        title: "Password Safe",
        username: "user",
        password: "testPassword",
        url: nil,
        notes: "This is a preview Entry, only to use in previews and tests",
        iconName: "folder",
        contents: [],
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
        lhs.contents == rhs.contents &&
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(iconName)
        hasher.combine(contents)
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
internal final class EncryptedEntry : GeneralEntry<Data, Data, Data, EncryptedToCItem>, EncryptedDataStructure {
    
    override internal init(
        title : Data,
        username : Data,
        password : Data,
        url : Data,
        notes : Data,
        iconName : Data,
        contents : [EncryptedToCItem],
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
            contents: contents,
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
        case contents
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
        try container.encode(contents, forKey: .contents)
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
            contents: try container.decode([EncryptedToCItem].self, forKey: .contents),
            created: try container.decode(Data.self, forKey: .created),
            lastEdited: try container.decode(Data.self, forKey: .lastEdited)
        )
    }
    
    internal init(from coreData : CD_Entry) {
        var localContents : [EncryptedToCItem] = []
        for toc in coreData.contents! {
            localContents.append(EncryptedToCItem(from: coreData))
        }
        super.init(
            title: coreData.title!,
            username: coreData.username!,
            password: coreData.password!,
            url: coreData.url!,
            notes: coreData.notes!,
            iconName: coreData.iconName!,
            contents: localContents,
            created: coreData.created!,
            lastEdited: coreData.lastEdited!
        )
    }
}
