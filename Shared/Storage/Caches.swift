//
//  DatabaseCache.swift
//  Protecto Pass
//
//  Created by Julian Schumacher as DatabaseCache.swift on 27.08.23.
//
//  Renamed by Julian Schumacher to Caches.swift on 09.03.24
//

import Foundation

/// Protocol to conform to if
/// the Struct or class implements a Database
/// Cache
internal protocol DatabaseCache {
    
    associatedtype Database
    
    /// The cache itself
    static var allDatabases : [Database] { get }
    
    /// Returns the database with the matching id, if it exists in the cache,
    /// otherwise throws an Error
    static func accessCache(id : UUID) throws -> Database
    
    /// Updates/replaces the database in the cache with the matching id, with the
    /// new provided Database
    static func update(id : UUID, with new : Database) -> Void
    
    /// Returns whether the database exists in this cache or not
    static func databaseExists(id : UUID) -> Bool
}

/// Error thrown when the Cache tries to access a Database
/// that does not exist, at least not in this particular Cache
internal struct DatabaseDoesNotExistError : Error {}
