//
//  DB_Image.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 30.08.23.
//

import Foundation
import UIKit

internal enum ImageType : String, RawRepresentable {
    case JPG
    
    case PNG
}

internal struct UnknownImageType : Error {}

/// The General super class of the DB Images
internal class General_DB_Image<I, T, Q>  {
    
    /// The actual Image or data of it
    internal let image : I
    
    /// The Type it was stored in
    internal let type : T
    
    /// The compression quality if the Type was
    /// jpeg
    internal let quality : Q
    
    internal init(image : I, type : T, quality : Q) {
        self.image = image
        self.type = type
        self.quality = quality
    }
}

internal final class DB_Image : General_DB_Image<UIImage, ImageType, Double?> {}

internal final class Encrypted_DB_Image : General_DB_Image<Data, Data, Data?> {
    
    override internal init(image: Data, type: Data, quality: Data?) {
        super.init(image: image, type: type, quality: quality)
    }
    
    internal convenience init(from coreData : CD_Image) {
        self.init(image: coreData.imageData!, type: coreData.dataType!, quality: coreData.compressionQuality)
    }
}
