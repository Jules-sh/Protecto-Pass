//
//  Entry.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 28.03.23.
//

import Foundation
import SwiftUI

internal class GeneralEntry<D, U, I, De, Do> : DatabaseContent<I, De, Do> {
    
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
        documents : Do,
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
internal final class Entry : GeneralEntry<String, URL?, String, Date, [Data]>, DecryptedDataStructure {
    
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
        lhs.lastEdited == rhs.lastEdited
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
internal final class EncryptedEntry : GeneralEntry<Data, Data, Data, Data, Data> {
    
    override internal init(
        title : Data,
        username : Data,
        password : Data,
        url : Data,
        notes : Data,
        iconName : Data,
        documents : Data,
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
    
    internal init(from coreData : CD_Entry) {
        super.init(
            title: coreData.title!,
            username: coreData.username!,
            password: coreData.password!,
            url: coreData.url!,
            notes: coreData.notes!,
            iconName: coreData.iconName!,
            documents: coreData.documents!,
            created: coreData.created!,
            lastEdited: coreData.lastEdited!
        )
    }
}
