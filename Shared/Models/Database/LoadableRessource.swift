//
//  LoadableRessource.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 04.05.24.
//

import Foundation

internal class GeneralLoadableRessource<N> {
    
    internal init(id: UUID, name: N, thumbnailData: Data) {
        self.id = id
        self.name = name
        self.thumbnailData = thumbnailData
    }
    
    internal let id : UUID
    
    internal let name : N
    
    internal let thumbnailData : Data
}

internal final class LoadableRessource : GeneralLoadableRessource<String> {
    
}

internal final class EncryptedLoadableRessource : GeneralLoadableRessource<Data> {
    
}
