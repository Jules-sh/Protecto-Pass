//
//  NativeType.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 31.08.23.
//

import Foundation

/// Superclass of every Native Type implemented in this App, that could not have
/// been implemented with a default Type
internal class NativeType<DE, DA> : DatabaseContent<DE>, ObservableObject {
    
    /// The Name of the SF-Symbol representing what this
    /// Database Content is
    @Published internal var iconName : DA
    
    internal init(
        iconName: DA,
        created : DE,
        lastEdited : DE,
        id : UUID
    ) {
        self.iconName = iconName
        super.init(created: created, lastEdited: lastEdited, id: id)
    }
}
