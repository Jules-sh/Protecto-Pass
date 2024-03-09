//
//  DatabaseContent.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 29.08.23.
//

import Foundation

/// The Super class of most Database Content Objects
/// that are stored within the App
internal class DatabaseContent<D, I> {
    
    /// The Date of creation for this Object
    internal let created : D
    
    /// The last edit date indicates when this
    /// Object was edited the last time
    internal var lastEdited : D
    
    internal var id : I
    
    internal init(
        created : D,
        lastEdited : D,
        id : I
    ) {
        self.created = created
        self.lastEdited = lastEdited
        self.id = id
    }
}
