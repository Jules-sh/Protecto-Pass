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

internal class GeneralToCItem<N> {
    
    internal var name : N
    
    internal var type : ContentType
    
    internal var id : UUID
    
    internal init(name: N, type: ContentType, id: UUID) {
        self.name = name
        self.type = type
        self.id = id
    }
}


internal final class ToCItem : GeneralToCItem<String>, DecryptedDataStructure {
    static func == (lhs: ToCItem, rhs: ToCItem) -> Bool {
        return lhs.name == rhs.name && lhs.type == rhs.type && lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(type)
        hasher.combine(id)
    }
}

internal final class EncryptedToCItem : GeneralToCItem<Data>, EncryptedDataStructure {
    enum ToCItemCodingKeys: CodingKey {
        case name
        case type
        case id
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: ToCItemCodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(type.rawValue, forKey: .type)
        try container.encode(id, forKey: .id)
    }
    
    internal convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ToCItemCodingKeys.self)
        self.init(
            name: try container.decode(Data.self, forKey: .name),
            type: ContentType(rawValue: try container.decode(Data.self, forKey: .type))!,
            id: try container.decode(UUID.self, forKey: .id)
        )
    }
}
