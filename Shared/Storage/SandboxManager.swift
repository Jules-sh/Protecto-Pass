//
//  SandboxManager.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 08.04.24.
//

import Foundation

internal struct SandboxManager {
    
    private static let fileManager : FileManager = FileManager.default
    
    private static let tempDir : URL = fileManager.temporaryDirectory
    
    internal static func loadToSandbox(
        forDB db : EncryptedDatabase,
        withEntries : [EncryptedEntry],
        folders: [EncryptedFolder],
        documents : [Encrypted_DB_Document],
        images : [Encrypted_DB_Image]
    ) throws -> Void {
        let archiver : NSKeyedArchiver = NSKeyedArchiver(requiringSecureCoding: true)
        let rootDir : URL = tempDir.appendingPathExtension(db.id.uuidString)
        try fileManager.createDirectory(at: rootDir, withIntermediateDirectories: true)
        for folder in folders {
            // let folderPath : URL = 
            try fileManager.createDirectory(at: <#T##URL#>, withIntermediateDirectories: <#T##Bool#>)
        }
    }
    
    private static func createSubs(for folder : EncryptedToCItem, atPath path : URL) -> Void {
        for child in folder.children {
            let path : URL = rootDir.appendingPathExtension(content.id.uuidString)
            if child.type == .folder {
                try fileManager.createDirectory(at: path, withIntermediateDirectories: true)
                createSubs(for: child)
            } else {
                // TODO: add data
                fileManager.createFile(atPath: path.absoluteString, contents: Data())
            }
        }
    }
    
    internal static func clearSandbox() throws -> Void {
        try fileManager.removeItem(at: tempDir) // TODO: does this work?
    }
}
