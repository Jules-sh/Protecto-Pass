//
//  CD_Database+CoreDataClass.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 28.03.23.
//
//

import Foundation
import CoreData

@objc(CD_Database)
public class CD_Database: NSManagedObject {
    
    /// The Preview Database to use in Previews and Test.
    ///
    /// DO NOT USE IN PRODUCTION.
    ///
    /// This Database uses the Preview View Context of the Persistence
    /// Manager, meaning, if this is used in production, the App
    /// will crash due to an uncaught Error with different Persistence
    /// Stores.
    internal static var previewDB : CD_Database {
        let db : CD_Database = CD_Database(context: PersistenceController.preview.container.viewContext)
        db.name = "Preview Database"
        db.dbDescription = "This is the Preview Database"
        return db
    }
}
