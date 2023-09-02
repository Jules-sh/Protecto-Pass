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
internal final class EncryptedEntry : GeneralEntry<Data, Data, Data, Data, Encrypted_DB_Document> {
    
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
    
    internal convenience init(from json : [String : Any]) {
        var localDocuments : [Encrypted_DB_Document] = []
        let jsonDocuments : [[String : String]] = json["documents"] as! [[String : String]]
        for jsonDocument in jsonDocuments {
            localDocuments.append(Encrypted_DB_Document(from: jsonDocument))
        }
        self.init(
            title: json["title"] as! Data,
            username: json["username"] as! Data,
            password: json["password"] as! Data,
            url: json["url"] as! Data,
            notes: json["notes"] as! Data,
            iconName: json["iconName"] as! Data,
            documents: localDocuments,
            created: json["created"] as! Data,
            lastEdited: json["lastEdited"] as! Data
        )
    }
    
    /// Parses this Object to a json dictionary and returns it
    internal func parseJSON() -> [String : Any] {
        var localDocuments : [[String : String]] = []
        for document in documents {
            localDocuments.append(document.parseJSON())
        }
        let json : [String : Any] = [
            "title" : title.base64EncodedString(),
            "username" : username.base64EncodedString(),
            "password" : password.base64EncodedString(),
            "url" : url.base64EncodedString(),
            "notes" : notes.base64EncodedString(),
            "iconName" : iconName.base64EncodedString(),
            "documents" : localDocuments,
            "created" : created.base64EncodedString(),
            "lastEdited" : lastEdited.base64EncodedString()
        ]
        return json
    }
}
