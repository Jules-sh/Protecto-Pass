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
    
    internal static func dateToData(_ date : Date) -> Data {
        return stringToData(dateToString(date))
    }
    
    internal static func dataToDate(_ data : Data) throws -> Date {
        return try stringToDate(dataToString(data))
    }
    
    internal static func imageToData(_ image : DB_Image) throws -> Data {
        if image.type == .JPG {
            assert(image.quality != nil)
            return image.image.jpegData(compressionQuality: CGFloat(image.quality!))!
        } else if image.type == .PNG {
            return image.image.pngData()!
        } else {
            throw UnknownImageType()
        }
    }
    
    internal static func doubleToData(_ double : Double) -> Data {
        return stringToData(String(double))
    }
    
    internal static func dataToDouble(_ data : Data) -> Double {
        return Double(dataToString(data))!
    }
}
