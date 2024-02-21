//
//  NativeType.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 31.08.23.
//

import Foundation

/// Superclass of every Native Type implemented in this App, that could not have
/// been implemented with a default Type
internal class NativeType<DE, DA, T, I> : DatabaseContent<DE, I>, ObservableObject {
    
    /// The Name of the SF-Symbol representing what this
    /// Database Content is
    @Published internal var iconName : DA
    
    /// All the documents connected to this Database
    /// Content
    @Published internal var contents : [T]
    
    internal init(
        iconName: DA,
        contents : [T],
        created : DE,
        lastEdited : DE,
        id : I
    ) {
        self.iconName = iconName
        self.contents = contents
        super.init(created: created, lastEdited: lastEdited, id: id)
    }
}
