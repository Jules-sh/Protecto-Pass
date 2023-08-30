//
//  DataConverter.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 21.08.23.
//

import Foundation

internal struct DataConverter {
    
    /// Converts the passed String to Data (Bytes)
    internal static func stringToData(_ string : String) -> Data {
        return Data(string.utf8.map { UInt8($0) })
    }
    
    internal static func dataToString(_ data : Data) -> String {
        return String(data: data, encoding: .utf8)!
    }
    
    internal static func stringToDate(_ string : String) throws -> Date {
        return try Date(string, strategy: .iso8601)
    }
    
    internal static func dateToString(_ date : Date) -> String {
        return date.ISO8601Format(.iso8601)
    }
}
