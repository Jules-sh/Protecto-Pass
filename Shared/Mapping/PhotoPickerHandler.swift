//
//  PhotoPickerHandler.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 26.08.24.
//

import Foundation
import SwiftUI
import PhotosUI
import CoreData

internal struct PhotoPickerHandler {
    
    internal static nonisolated func handlePhotoPickerInput(
        items : [PhotosPickerItem],
        pickerPresented : Bool,
        images : Binding<[DB_Image]>,
        videos : Binding<[DB_Video]>,
        storeIn db : Database,
        with context : NSManagedObjectContext,
        onSuperID superID : UUID
    ) async throws -> Void {
        // Guard to not call this code when opening the Picker
        guard !pickerPresented else { return }
        var selectedDB_Videos : [DB_Video] = []
        var selectedDB_Images : [DB_Image] = []
        for item in items {
            if item.supportedContentTypes.contains(where: { $0.isSubtype(of: .audiovisualContent ) }) {
                do {
                    let video = try await item.loadTransferable(type: DBSoleVideo.self)!.videoData
                    selectedDB_Videos.append(
                        DB_Video(
                            video: video,
                            created: Date.now,
                            lastEdited: Date.now,
                            id: UUID()
                        )
                    )
                } catch {
                    throw PhotoPickerVideoConverterError()
                }
            } else if item.supportedContentTypes.contains(where: { $0.isSubtype(of: .image) }) {
                do {
                    let image : UIImage = try await item.loadTransferable(type: DBSoleImage.self)!.image
                    selectedDB_Images.append(
                        DB_Image(
                            image: image,
                            quality: 0.5,
                            created: Date.now,
                            lastEdited: Date.now,
                            id: UUID()
                        )
                    )
                } catch {
                    throw PhotoPickerImageConverterError()
                }
            } else {
                
            }
        }
        do {
            var newElements : [DatabaseContent<Date>] = []
            newElements.append(contentsOf: selectedDB_Images)
            newElements.append(contentsOf: selectedDB_Videos)
            try Storage.storeDatabase(
                db,
                context: context,
                newElements: newElements,
                superID: superID
            )
            images.wrappedValue.append(contentsOf: selectedDB_Images)
            videos.wrappedValue.append(contentsOf: selectedDB_Videos)
        } catch {
            throw PhotoPickerResultsSavingError()
        }
    }
}

/// The Struct representing the loaded image in this View
private struct DBSoleImage : Transferable {
    
    /// The Image when loading has completed
    fileprivate let image : UIImage
    
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(importedContentType: .image) {
            data in
            guard let image = UIImage(data: data) else {
                throw ImageLoadingError()
            }
            return DBSoleImage(image: image)
        }
    }
}

/// The Struct representing the loaded image in this View
private struct DBSoleVideo : Transferable {
    
    /// The Image when loading has completed
    fileprivate let videoData : Data
    
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(importedContentType: .movie) {
            data in
            return DBSoleVideo(videoData: data)
        }
    }
}
