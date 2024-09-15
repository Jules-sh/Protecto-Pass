//
//  FileImportHandler.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 15.09.24.
//

import Foundation
import SwiftUI
import CoreData

internal struct FileImportHandler {
    
    internal static func handleDocumentPickerInput(
        result : Result<[URL], any Error>,
        documents : Binding<[DB_Document]>,
        storeIn db : Database,
        context : NSManagedObjectContext
    ) throws -> Void {
        switch result {
            case .success(let files):
                var documents : [DB_Document] = []
                for file in files {
                    guard file.startAccessingSecurityScopedResource() else { return }
                    do {
                        let data = try Data(contentsOf: file, options: [.uncached])
                        documents.append(
                            DB_Document(
                                document: data,
                                type: file.pathExtension.lowercased(),
                                name: file.lastPathComponent,
                                created: Date.now,
                                lastEdited: Date.now,
                                id: UUID()
                            )
                        )
                    } catch {
                        throw DocumentLoadingError()
                    }
                    file.stopAccessingSecurityScopedResource()
                }
                documents.append(contentsOf: documents)
                do {
                    try Storage.storeDatabase(db, context: context, newElements: documents)
                } catch {
                    throw DocumentSavingError()
                }
            case .failure:
                throw DocumentLoadingError()
        }
    }
}
