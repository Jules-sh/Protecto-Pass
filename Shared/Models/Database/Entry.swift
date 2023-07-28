//
//  Entry.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 28.03.23.
//

import Foundation

/// The Struct representing an Entry
/// while this App is running
internal struct Entry : Identifiable {
    
    internal let id: UUID = UUID()
    
    /// The Title of this Entry describing
    /// what it stores
    internal let title : String
    
    /// The Username or login name
    /// to this Entry
    internal let username : String
    
    /// The Password of this Entry being stored here.
    /// This is in the already decrypted state
    internal let password : String
    
    /// The URL / Link to a website if
    /// this Entry is connected to a
    /// web platform
    internal let url : URL?
    
    /// Notes to this Entry storing whatever
    /// the User wants to write down here
    internal let notes : String
}

/// The Encrypted Entry storing all the
/// Data of an Entry secure and encrypted
internal struct EncryptedEntry {
    
    /// The Title encrypted and stores as bytes
    internal let title : Data
    
    /// The Username encrypted and stores as bytes
    internal let username : Data
    
    /// The Password encrypted, safe and securely stores
    /// as bytes
    internal let password : Data
    
    /// The URL stores as Bytes
    internal let url : Data
    
    /// The Notes encrypted and stored as bytes
    internal let notes : Data
    
    internal init(
        title : Data,
        username : Data,
        password : Data,
        url : Data,
        notes : Data
    ) {
        self.title = title
        self.username = username
        self.password = password
        self.url = url
        self.notes = notes
    }
    
    internal init(from coreData : CD_Entry) {
        title = coreData.title!
        username = coreData.username!
        password = coreData.password!
        url = coreData.url!
        notes = coreData.notes!
    }
}
