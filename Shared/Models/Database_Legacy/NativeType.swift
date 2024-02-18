//
//  NativeType.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 31.08.23.
//

import Foundation

/// Superclass of every Native Type implemented in this App, that could not have
/// been implemented with a default Type
internal class NativeType<De, I, Do> : DatabaseContent<De>, ObservableObject {
    
    /// The Name of the SF-Symbol representing what this
    /// Database Content is
    @Published internal var iconName : I
    
    /// All the documents connected to this Database
    /// Content
    @Published internal var documents : TableOfContents
    
    internal init(
        iconName: I,
        documents: [Do],
        created : De,
        lastEdited : De
    ) {
        self.iconName = iconName
        self.documents = documents
        super.init(created: created, lastEdited: lastEdited)
    }
}
