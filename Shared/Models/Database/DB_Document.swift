//
//  DB_Document.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 31.08.23.
//

import Foundation

/// Generalised Document class
internal class GeneralDocument<T, De> : DatabaseContent<De> {
    
    /// Document Data read from this Document
    internal let document : Data
    
    /// The Type or extension of this Document
    internal let type : T
    
    internal init(
        document: Data,
        type: T,
        created : De,
        lastEdited : De
    ) {
        self.document = document
        self.type = type
        super.init(created: created, lastEdited: lastEdited)
    }
}


/// Decrypted Document to use in the decrypted Database
internal final class DB_Document : GeneralDocument<String, Date>, DecryptedDataStructure {
    
    /// ID to conform to Identifiable
    internal let id: UUID = UUID()
    
    internal static func == (lhs: DB_Document, rhs: DB_Document) -> Bool {
        return lhs.document == rhs.document && lhs.type == rhs.type && lhs.id == rhs.id
    }
    
    internal func hash(into hasher: inout Hasher) {
        hasher.combine(document)
        hasher.combine(type)
        hasher.combine(id)
    }
}

/// Encrypted Document type storing the encrypted values
internal final class Encrypted_DB_Document : GeneralDocument<Data, Data>, EncryptedDataStructure {
    
    override internal init(
        document: Data,
        type: Data,
        created : Data,
        lastEdited : Data
    ) {
        super.init(
            document: document,
            type: type,
            created: created,
            lastEdited: lastEdited
        )
    }
    
    private enum DB_DocumentCodingKeys: CodingKey {
        case document
        case type
        case created
        case lastEdited
    }
    
    internal func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: DB_DocumentCodingKeys.self)
        try container.encode(document, forKey: .document)
        try container.encode(type, forKey: .type)
        try container.encode(created, forKey: .created)
        try container.encode(lastEdited, forKey: .lastEdited)
    }
    
    internal convenience init(from decoder: Decoder) throws {
        let container : KeyedDecodingContainer = try decoder.container(keyedBy: DB_DocumentCodingKeys.self)
        self.init(
            document: try container.decode(Data.self, forKey: .document),
            type: try container.decode(Data.self, forKey: .type),
            created: try container.decode(Data.self, forKey: .created),
            lastEdited: try container.decode(Data.self, forKey: .lastEdited)
        )
    }
    
    internal convenience init(from coreData : CD_Document) {
        self.init(
            document: coreData.documentData!,
            type: coreData.type!,
            created: coreData.created!,
            lastEdited: coreData.lastEdited!
        )
    }
}
