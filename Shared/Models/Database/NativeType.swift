//
//  NativeType.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 31.08.23.
//

import Foundation

/// Superclass of every Native Type implemented in this App, that could not have
/// been implemented with a default Type
internal class NativeType<De, I, Do> : DatabaseContent<De> {
    
    /// The Name of the SF-Symbol representing what this
    /// Database Content is
    internal let iconName : I
    
    /// All the documents connected to this Database
    /// Content
    internal let documents : [Do]
    
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
