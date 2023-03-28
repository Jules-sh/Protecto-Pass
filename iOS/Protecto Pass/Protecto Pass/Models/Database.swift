//
//  Database.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 28.03.23.
//

import Foundation

/// The Database Object that is used when the App is running
internal struct Database {
    
    /// The Name of the Database
    internal let name : String
    
    /// The Description of this Databse
    internal let dbDescription : String
    
    /// The Preview Database to use in Previews or Tests
    internal static let previewDB : Database = Database(name: "Preview Database", dbDescription: "This is a Preview Database used in Tests and Previews")
}
