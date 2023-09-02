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
internal final class Encrypted_DB_Document : GeneralDocument<Data, Data> {
    
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
    
    internal convenience init(from coreData : CD_Document) {
        self.init(
            document: coreData.documentData!,
            type: coreData.type!,
            created: coreData.created!,
            lastEdited: coreData.lastEdited!
        )
    }
    
    internal convenience init(from json : [String : String]) {
        self.init(
            document: json["document"]!,
            type: json["type"]!,
            created: json["created"]!,
            lastEdited: json["lastEdited"]!
        )
    }
    
    internal func parseJSON() -> [String : String] {
        let json : [String : String] = [
            "document" : document.base64EncodedString(),
            "type" : type.base64EncodedString(),
            "created" : created.base64EncodedString(),
            "lastEdited" : lastEdited.base64EncodedString()
        ]
        return json
    }
}
