//
//  LoadableResource.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 04.05.24.
//

import Foundation

internal class GeneralLoadableResource<N> {
    
    internal init(id: UUID, name: N, thumbnailData: Data) {
        self.id = id
        self.name = name
        self.thumbnailData = thumbnailData
    }
    
    internal let id : UUID
    
    internal let name : N
    
    internal let thumbnailData : Data
}

internal final class LoadableResource : GeneralLoadableResource<String> {
    
}

internal final class EncryptedLoadableResource : GeneralLoadableResource<Data>, EncryptedDataStructure {
    
    private enum LoadableResourceCodingKeys: CodingKey {
        case id
        case name
        case thumbnailData
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: LoadableResourceCodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(thumbnailData, forKey: .thumbnailData)
    }
    
    internal override init(id: UUID, name: Data, thumbnailData: Data) {
        super.init(
            id: id,
            name: name,
            thumbnailData: thumbnailData
        )
    }
    
    internal convenience init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: LoadableResourceCodingKeys.self)
        self.init(
            id: try container.decode(UUID.self, forKey: .id),
            name: try container.decode(Data.self, forKey: .name),
            thumbnailData: try container.decode(Data.self, forKey: .thumbnailData)
        )
    }
    
    internal convenience init(from coreData : CD_LoadableResource) {
        self.init(
            id: coreData.id!,
            name: coreData.name!,
            thumbnailData: coreData.thumbnailData!
        )
    }
}
