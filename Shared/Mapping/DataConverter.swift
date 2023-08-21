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
}
