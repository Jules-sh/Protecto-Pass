//
//  DB_Image.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 30.08.23.
//

import Foundation
import UIKit

/// The General super class of the DB Images
internal class General_DB_Image<I, Q, De> : DatabaseContent<De> {
    
    /// The actual Image or data of it
    internal let image : I
    
    /// The compression quality if the Type was
    /// jpeg
    internal let quality : Q
    
    internal init(
        image : I,
        quality : Q,
        created : De,
        lastEdited : De
    ) {
        self.image = image
        self.quality = quality
        super.init(created: created, lastEdited: lastEdited)
    }
}

/// The Decrypted Data Structure for Images stored in this App
internal final class DB_Image : General_DB_Image<UIImage, Double, Date>, DecryptedDataStructure {
    
    /// ID to conform to identifiable protocol
    internal let id: UUID = UUID()
    
    static func == (lhs: DB_Image, rhs: DB_Image) -> Bool {
        return lhs.image == rhs.image && lhs.quality == rhs.quality && lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(image)
        hasher.combine(quality)
        hasher.combine(id)
    }
    
    /// The preview Image to use in SwiftUI Previews
    internal static let previewImage : DB_Image = DB_Image(
        image: UIImage(systemName: "car")!,
        quality: 0.8,
        created: Date.now,
        lastEdited: Date.now
    )
}

/// The Encrypted Data Structure being used when the Database is still encrypted.
internal final class Encrypted_DB_Image : General_DB_Image<Data, Data, Data>, EncryptedDataStructure {
    
    override internal init(
        image: Data,
        quality: Data,
        created : Data,
        lastEdited : Data
    ) {
        super.init(
            image: image,
            quality: quality,
            created: created,
            lastEdited: lastEdited
        )
    }
    
    private enum DB_ImageCodingKeys: CodingKey {
        case image
        case quality
        case created
        case lastEdited
    }
    
    internal func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: DB_ImageCodingKeys.self)
        try container.encode(image, forKey: .image)
        try container.encode(quality, forKey: .quality)
        try container.encode(created, forKey: .created)
        try container.encode(lastEdited, forKey: .lastEdited)
    }
    
    internal convenience init(from decoder: Decoder) throws {
        let container : KeyedDecodingContainer = try decoder.container(keyedBy: DB_ImageCodingKeys.self)
        self.init(
            image: try container.decode(Data.self, forKey: .image),
            quality: try container.decode(Data.self, forKey: .quality),
            created: try container.decode(Data.self, forKey: .created),
            lastEdited: try container.decode(Data.self, forKey: .lastEdited)
        )
    }
    
    internal convenience init(from coreData : CD_Image) {
        self.init(
            image: coreData.imageData!,
            quality: coreData.compressionQuality!,
            created: coreData.created!,
            lastEdited: coreData.lastEdited!
        )
    }
}
