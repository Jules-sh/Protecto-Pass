//
//  DB_Video.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 02.06.24.
//

import Foundation

/// The general super class of all Videos stored in this App
internal class General_DB_Video<DA, DE> : DatabaseContent<DE> {
    
    /// The Video Data
    internal let video : DA
    
    internal init(
        video : DA,
        created : DE,
        lastEdited : DE,
        id: UUID
    ) {
        self.video = video
        super.init(created: created, lastEdited: lastEdited, id: id)
    }
}

/// The decrypted Data Strcuture for Videos stored in this App
internal final class DB_Video : General_DB_Video<Data, Date> {
    
}

/// The encrypted Data Strcuture for Videos stored in this App
internal final class Encrypted_DB_Video : General_DB_Video<Data, Data> {
    
}
