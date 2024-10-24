//
//  ME_ContentViewImageSection.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 24.09.24.
//

import SwiftUI
import PhotosUI

internal struct ME_ContentViewImageSection: View {
    
    @Environment(\.managedObjectContext) private var context
    
    @EnvironmentObject private var db : Database
    
    @ObservedObject private var dataStructure : ME_DataStructure<String, Date, Folder, Entry, LoadableResource>
    
    private var metrics : GeometryProxy
    
    internal init(
        dataStructure: ME_DataStructure<String, Date, Folder, Entry, LoadableResource>,
        metrics : GeometryProxy,
        errSavingPresented : Binding<Bool>,
        audioVisualItemsToAdd : Binding<[PhotosPickerItem]>
    ) {
        self.dataStructure = dataStructure
        self.metrics = metrics
        self.errSavingPresented = errSavingPresented
        self.audioVisualItemsToAdd = audioVisualItemsToAdd
    }
    
    /* DATA VARIABLES */
    
    @State private var images : [DB_Image] = []
    
    @State private var videos : [DB_Video] = []
    
    /* SELECTED OBJECT VARIABLES */
    
    @State private var selectedImage : DB_Image?
    
    @State private var selectedVideo : DB_Video?
    
    /* SHEET CONTROL VARIABLES */
    
    @State private var imageDetailsPresented : Bool = false
    
    @State private var addImagePresented : Bool = false
    
    /* DELETION CONFIRMATION DIALOG CONTROL VARIABLES */
    
    @State private var imageDeletionConfirmationShown : Bool = false
    
    @State private var videoDeletionConfirmationShown : Bool = false
    
    /* ERROR ALERT CONTROL VARIABLES */
    
    @State private var errImageDeletionShown : Bool = false
    
    @State private var errVideoDeletionShown : Bool = false
    
    /// Set to true in order to present an alert stating the error while loading an image
    @State private var errLoadingImagePresented : Bool = false
    
    /// Set to true in order to present an alert displaying an error while loading the video
    @State private var errLoadingVideoPresented : Bool = false
    
    private let errSavingPresented : Binding<Bool>
    
    /// The Photos and videos selected to add to the Password Safe
    private var audioVisualItemsToAdd : Binding<[PhotosPickerItem]>
    
    /// Displays an alert displaying an error while loading resources
    @State private var errLoadingResourcesShown : Bool = false
    
    /// Loads images and videos and stores them in the corresponding variables
    private func loadResources() -> Void {
        var imageIDs : [UUID] = []
        var videoIDs : [UUID] = []
        dataStructure.images.forEach({ imageIDs.append($0.id) })
        dataStructure.videos.forEach({ videoIDs.append($0.id) })
        do {
            images = try Storage.loadImages(db, ids: imageIDs, context: context)
            videos = try Storage.loadVideos(db, ids: videoIDs, context: context)
        } catch {
            errLoadingResourcesShown.toggle()
        }
    }
    
    
    var body: some View {
        Section("Images") {
            if !images.isEmpty {
                if images.count <= 9 {
                    GroupBox {
                        LazyVGrid(
                            columns: [
                                GridItem(
                                    .fixed(metrics.size.width / 3),
                                    spacing: 2
                                ),
                                GridItem(
                                    .fixed(metrics.size.width / 3),
                                    spacing: 2
                                ),
                                GridItem(
                                    .fixed(metrics.size.width / 3),
                                    spacing: 2
                                ),
                            ],
                            spacing: 2
                        ) {
                            ForEach(images) {
                                image in
                                Button {
                                    selectedImage = image
                                    imageDetailsPresented.toggle()
                                } label: {
                                    Image(uiImage: image.image)
                                        .resizable()
                                        .frame(
                                            width: metrics.size.width / 3,
                                            height: metrics.size.width / 3
                                        )
                                }
                                .contextMenu {
                                    Button(role: .destructive) {
                                        selectedImage = image
                                        imageDeletionConfirmationShown.toggle()
                                    } label: {
                                        Label("Delete Image", systemImage: "trash")
                                    }
                                }
                                .sheet(isPresented: $imageDetailsPresented) {
                                    ImageDetails(image: $selectedImage, deleted: $imageDeletionConfirmationShown)
                                }
                                .alert("Delete Image?", isPresented: $imageDeletionConfirmationShown) {
                                    Button("Continue", role: .destructive) {
                                        let loadableResource : LoadableResource = dataStructure.images.first(where: { $0.id == selectedImage!.id })!
                                        do {
                                            images.removeAll(where: { $0.id == selectedImage!.id })
                                            dataStructure.images.removeAll(where: { $0.id == selectedImage!.id })
                                            try Storage.deleteImage(id: selectedImage!.id, in: db, with: context)
                                        } catch {
                                            images.append(selectedImage!)
                                            dataStructure.images.append(loadableResource)
                                            errImageDeletionShown = true
                                        }
                                    }
                                    Button("Cancel", role: .cancel) {
                                        imageDeletionConfirmationShown.toggle()
                                    }
                                } message: {
                                    Text("This Image will be deleted\nThis action is irreversible")
                                }
                                .alert("Delete Video?", isPresented: $videoDeletionConfirmationShown) {
                                    Button("Continue", role: .destructive) {
                                        let loadableResource : LoadableResource = dataStructure.videos.first(where: { $0.id == selectedVideo!.id })!
                                        do {
                                            videos.removeAll(where: { $0.id == selectedImage!.id })
                                            dataStructure.videos.removeAll(where: { $0.id == selectedImage!.id })
                                            try Storage.deleteVideo(id: selectedVideo!.id, in: db, with: context)
                                        } catch {
                                            videos.append(selectedVideo!)
                                            dataStructure.videos.append(loadableResource)
                                            errVideoDeletionShown = true
                                        }
                                    }
                                    Button("Cancel", role: .cancel) {
                                        videoDeletionConfirmationShown.toggle()
                                    }
                                } message: {
                                    Text("This Video will be deleted\nThis action is irreversible")
                                }
                                .alert("Error deleting Image", isPresented: $errImageDeletionShown) {
                                } message: {
                                    Text("There's been an error deleting the Image")
                                }
                                .alert("Error deleting Video", isPresented: $errVideoDeletionShown) {
                                } message: {
                                    Text("There's been an error deleting the Video")
                                }
                            }
                        }
                    }
                } else {
                    NavigationLink {
                        ImageListDetails(images: $images, videos: $videos, superID: dataStructure.id)
                            .environmentObject(db)
                    } label: {
                        Label("Show all images (\(images.count))", systemImage: "photo")
                    }
                    .foregroundStyle(.primary)
                }
            } else {
                Text("No Images found")
            }
        }
        .onAppear {
            loadResources()
        }
        .alert("Error loading Image", isPresented: $errLoadingImagePresented) {
        } message: {
            Text("There's been an error while trying to load this image")
        }
        .alert("Error loading Video", isPresented: $errLoadingVideoPresented) {
        } message: {
            Text("There's been an error while trying to load this video")
        }
        .alert("Error loading resources", isPresented: $errLoadingResourcesShown) {
        } message: {
            Text("There's been an error while trying to load the resources from the file system")
        }
        .onChange(of: addImagePresented) {
            Task {
                do {
                    try await PhotoPickerHandler.handlePhotoPickerInput(
                        items: audioVisualItemsToAdd.wrappedValue,
                        pickerPresented: addImagePresented,
                        images: $images,
                        videos: $videos,
                        storeIn: db,
                        with: context,
                        onSuperID: dataStructure.id
                    )
                } catch is PhotoPickerImageConverterError {
                    errLoadingImagePresented.toggle()
                } catch is PhotoPickerVideoConverterError {
                    errLoadingVideoPresented.toggle()
                } catch is PhotoPickerResultsSavingError {
                    errSavingPresented.wrappedValue.toggle()
                }
            }
        }
    }
}

#Preview {
    
    @Previewable @State var dataStructure : ME_DataStructure<String, Date, Folder, Entry, LoadableResource> = Database.previewDB
    
    @Previewable @State var errSavingPresented : Bool = false
    
    @Previewable @State var audioVisualItemsToAdd : [PhotosPickerItem] = []
    
    List {
        GeometryReader {
            metrics in
            ME_ContentViewImageSection(
                dataStructure: dataStructure,
                metrics: metrics,
                errSavingPresented: $errSavingPresented,
                audioVisualItemsToAdd: $audioVisualItemsToAdd
            )
        }
    }
}
