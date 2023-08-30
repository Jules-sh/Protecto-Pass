//
//  DatabaseContent.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 29.08.23.
//

import Foundation

/// The Super class of most Database Content Objects
/// that are stored within the App
internal class DatabaseContent<I, De, Do> {
    
    /// The Name of the SF-Symbol representing what this
    /// Database Content is
    internal let iconName : I
    
    /// All the documents connected to this Database
    /// Content
    internal let documents : Do
    
    /// The Date of creation for this Object
    internal let created : De
    
    /// The last edit date indicates when this
    /// Object was edited the last time
    internal let lastEdited : De
    
    internal init(
        iconName : I,
        documents : Do,
        created : De,
        lastEdited : De
    ) {
        self.iconName = iconName
        self.documents = documents
        self.created = created
        self.lastEdited = lastEdited
    }
}
