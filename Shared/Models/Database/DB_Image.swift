//
//  DB_Image.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 30.08.23.
//

import Foundation
import UIKit

/// The Type chosen be the User to
/// convert the Image to when storing it.
internal enum ImageType : String, RawRepresentable {
    /// The JPG option has been chosen.
    /// This requires a compression quality parameter
    /// in the Image Type
    case JPG
    
    /// The PNG option has been chosen.
    /// The quality parameter is optional now
    /// and an be nil
    case PNG
}

/// The Image Type is unknown which resulted in an Error.
internal struct UnknownImageType : Error {}

/// The General super class of the DB Images
internal class General_DB_Image<I, T, Q, De> : DatabaseContent<De>  {
    
    /// The actual Image or data of it
    internal let image : I
    
    /// The Type it was stored in
    internal let type : T
    
    /// The compression quality if the Type was
    /// jpeg
    internal let quality : Q
    
    internal init(
        image : I,
        type : T,
        quality : Q,
        created : De,
        lastEdited : De
    ) {
        self.image = image
        self.type = type
        self.quality = quality
        super.init(created: created, lastEdited: lastEdited)
    }
}

/// The Decrypted Data Structure for Images stored in this App
internal final class DB_Image : General_DB_Image<UIImage, ImageType, Double, Date>, DecryptedDataStructure {
    
    /// ID to conform to identifiable protocol
    internal let id: UUID = UUID()
    
    static func == (lhs: DB_Image, rhs: DB_Image) -> Bool {
        return lhs.image == rhs.image && lhs.type == rhs.type && lhs.quality == rhs.quality && lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(image)
        hasher.combine(type)
        hasher.combine(quality)
        hasher.combine(id)
    }
}

/// The Encrypted Data Structure being used when the Database is still encrypted.
internal final class Encrypted_DB_Image : General_DB_Image<Data, Data, Data, Data> {
    
    override internal init(
        image: Data,
        type: Data,
        quality: Data,
        created : Data,
        lastEdited : Data
    ) {
        super.init(
            image: image,
            type: type,
            quality: quality,
            created: created,
            lastEdited: lastEdited
        )
    }
    
    internal convenience init(from coreData : CD_Image) {
        self.init(
            image: coreData.imageData!,
            type: coreData.dataType!,
            quality: coreData.compressionQuality!,
            created: coreData.created!,
            lastEdited: coreData.lastEdited!
        )
    }
    
    internal convenience init(from json : [String : String]) {
        self.init(
            image: json["image"]!,
            type: json["type"]!,
            quality: json["quality"]!,
            created: json["created"]!,
            lastEdited: json["lastEdited"]!
        )
    }
    
    /// Parses this Object to a json dictionary and returns it
    internal func parseJSON() -> [String : String] {
        let json : [String : String] = [
            "image" : image.base64EncodedString(),
            "type" : type.base64EncodedString(),
            "quality" : quality.base64EncodedString(),
            "created" : created.base64EncodedString(),
            "lastEdited" : lastEdited.base64EncodedString()
        ]
        return json
    }
}
