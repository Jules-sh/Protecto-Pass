//
//  TableOfContents.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 15.02.24.
//

import Foundation

// TODO: is this really needed?
// Explanation for todo: Is a table of contents really needed, or is it enough to replace it with
// an array of ToCItems? Because at the moment a table of contents only holds this one array.
// This will be obsolete if the table of contents will hold more attributes in the future
internal class GeneralTableOfContents<C> {
    internal var contents : [C]
    
    internal init(contents: [C]) {
        self.contents = contents
    }
}


internal final class TableOfContents : GeneralTableOfContents<ToCItem>, DecryptedDataStructure {
    static func == (lhs: TableOfContents, rhs: TableOfContents) -> Bool {
        return lhs.contents == rhs.contents
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(contents)
    }
}

internal final class EncryptedTableOfContents : GeneralTableOfContents<EncryptedToCItem>, EncryptedDataStructure {
    enum ToCCodingKeys: CodingKey {
        case contents
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: ToCCodingKeys.self)
        try container.encode(contents, forKey: .contents)
    }
    
    convenience init(from decoder: Decoder) throws {
        let container : KeyedDecodingContainer = try decoder.container(keyedBy: ToCCodingKeys.self)
        self.init(contents: try container.decode([EncryptedToCItem].self, forKey: .contents))
    }
}
