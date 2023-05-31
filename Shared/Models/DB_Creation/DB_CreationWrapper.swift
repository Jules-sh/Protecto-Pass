//
//  DB_CreationWrapper.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 31.05.23.
//

import Foundation

/// Wrapper to hold all Object in the Database Creation process.
/// Inherits Observable Object and may be used as State Object / Environment Object.
internal final class DB_CreationWrapper : ObservableObject {
    
    /// The Name of the Database
    internal final var name : String = ""
    
    /// The Database's description
    internal final var description : String = ""
    
    /// The Password the User chose to lock and unlock the Database with
    internal final var password : String = ""
    
    /// The Encryption Algorithm being used to encrypt the Database
    internal final var encryption : Cryptography.Encryption = .AES256
    
    /// The way the Databse should be stored
    internal final var storageType : DB_Header.StorageType = .CoreData
}
