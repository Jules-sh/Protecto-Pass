//
//  ToCItem.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 15.02.24.
//

import Foundation

internal struct ToCItem {
    
    internal var name : String
    
    internal var type : ContentType
    
    internal var id : UUID
    
    internal init(name: String, type: ContentType, id: UUID) {
        self.name = name
        self.type = type
        self.id = id
    }
}

internal enum ContentType : String, RawRepresentable {
    case image
    case folder
    case entry
    case document
}
