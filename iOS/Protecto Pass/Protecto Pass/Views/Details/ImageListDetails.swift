//
//  ImageListDetails.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 23.01.24.
//

import SwiftUI
import PhotosUI

internal struct ImageListDetails: View {
    
    @Environment(\.managedObjectContext) private var context
    
    /// The full database needed to store it
    @EnvironmentObject private var db : Database
    
    @Binding internal var images : [DB_Image]
    
    @Binding internal var videos : [DB_Video]
    
    @State private var imageDetailsPresented : Bool = false
    
    @State private var selectedImage : DB_Image?
    
    @State private var addImagePresented : Bool = false
    
    @State private var itemsSlected : [PhotosPickerItem] = []
    
    @State private var imageDeleted : Bool = false
    
    var body: some View {
        NavigationStack {
            GeometryReader {
                metrics in
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
                    }
                }
            }
            .photosPicker(
                isPresented: $addImagePresented,
                selection: $itemsSlected,
                maxSelectionCount: 100,
                selectionBehavior: .continuousAndOrdered,
                matching: .any(of: [.images, .videos]),
                preferredItemEncoding: .automatic
            )
            .onChange(of: addImagePresented) {
                Task {
                    do {
                        try await PhotoPickerHandler.handlePhotoPickerInput(
                            items: itemsSlected,
                            pickerPresented: addImagePresented,
                            images: $images,
                            videos: $videos,
                            storeIn: db,
                            with: context
                        )
                    }
                }
            }
            .onChange(of: imageDeleted) {
                let image = images.first(where: { $0.id == selectedImage!.id })
                images.removeAll(where: { $0 == image })
                // TODO: delete Image from database
            }
            .sheet(isPresented: $imageDetailsPresented) {
                ImageDetails(image: $selectedImage, deleted: $imageDeleted)
            }
            .navigationTitle("Images & Videos")
            .navigationBarTitleDisplayMode(.automatic)
            .toolbarRole(.automatic)
            .toolbar(.automatic, for: .automatic)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        addImagePresented.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
}


internal struct ImageListDetails_Previews: PreviewProvider {
    
    @State static private var images : [DB_Image] = [DB_Image.previewImage]
    
    @State static private var videos : [DB_Video] = []
    
    @StateObject static private var db : Database = Database.previewDB
    
    static var previews: some View {
        ImageListDetails(images: $images, videos: $videos)
            .environmentObject(db)
    }
}
