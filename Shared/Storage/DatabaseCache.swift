//
//  DatabaseCache.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 27.08.23.
//

import Foundation

internal protocol DatabaseCache {
    
    associatedtype Database
    
    static var allDatabases : [Database] { get }
    
    static func accessCache(id : UUID) throws -> Database
    
    static func update(id : UUID, with new : Database) -> Void
    
    static func databaseExists(id : UUID) -> Bool
}
