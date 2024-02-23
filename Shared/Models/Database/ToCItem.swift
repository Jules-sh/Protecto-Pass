//
//  ToCItem.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 15.02.24.
//

import Foundation

internal enum ContentType : String, RawRepresentable {
    case image
    case folder
    case entry
    case document
}

internal class GeneralToCItem<D, C, I, S> {
    
    internal var name : D
    
    internal var type : C
    
    internal var id : I
    
    internal var children : [S]
    
    internal init(name: D, type: C, id: I, children : [S]) {
        self.name = name
        self.type = type
        self.id = id
        self.children = children
    }
}


internal final class ToCItem : GeneralToCItem<String, ContentType, UUID, ToCItem>, DecryptedDataStructure {
    
    static func == (lhs: ToCItem, rhs: ToCItem) -> Bool {
        return lhs.name == rhs.name && lhs.type == rhs.type && lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(type)
        hasher.combine(id)
        hasher.combine(children)
    }
}

internal final class EncryptedToCItem : GeneralToCItem<Data, Data, Data, EncryptedToCItem>, EncryptedDataStructure {
    enum ToCItemCodingKeys: CodingKey {
        case name
        case type
        case id
        case children
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: ToCItemCodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(type, forKey: .type)
        try container.encode(id, forKey: .id)
    }
    
    internal convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ToCItemCodingKeys.self)
        self.init(
            name: try container.decode(Data.self, forKey: .name),
            type: try container.decode(Data.self, forKey: .type),
            id: try container.decode(Data.self, forKey: .id),
            children: try container.decode([EncryptedToCItem].self, forKey: .children)
        )
    }
    
    internal convenience init(from coreData : CD_ToCItem) {
        var localContents : [EncryptedToCItem] = []
        for toc in coreData.children! {
            localContents.append(EncryptedToCItem(from: toc as! CD_ToCItem))
        }
        self.init(
            name: coreData.name!,
            type: coreData.type!,
            id: coreData.uuid!,
            children: localContents
        )
    }
}
