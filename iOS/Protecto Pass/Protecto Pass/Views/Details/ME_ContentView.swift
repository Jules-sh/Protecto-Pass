//
//  ME_ContentView.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 22.08.23.
//

import SwiftUI
import PhotosUI

internal struct ME_ContentView : View {
    
    @Environment(\.managedObjectContext) private var context
    
    /// Controls the navigation flow, only necessary if this represents a Database
    @EnvironmentObject private var navigationController : AddDB_Navigation
    
    /// Whether the User activated the large Screen preference or not
    @Environment(\.largeScreen) private var largeScreen : Bool
    
    @EnvironmentObject private var db : Database
    
    internal init(_ data : ME_DataStructure<String, Folder, Entry, Date, DB_Document, DB_Image>) {
        dataStructure = data
    }
    
    /// The Data Structure which is displayed in this View
    private let dataStructure : ME_DataStructure<String, Folder, Entry, Date, DB_Document, DB_Image>
    
    /// Whether or not the details sheet is presented
    @State private var detailsPresented : Bool = false
    
    /// Whether or not the sheet to add an entry is presented
    @State private var addEntryPresented : Bool = false
    
    /// Whether or not the sheet to add a folder is presented
    @State private var addFolderPresented : Bool = false
    
    /// Whether or not the sheet to add an image is presented
    @State private var addImagePresented : Bool = false
    
    /// Whether or not the sheet to add a document is presented
    @State private var addDocPresented : Bool = false
    
    /// The Photos selected to add to the Password Safe
    @State private var photosSelected : [PhotosPickerItem] = []
    
    /// Set to true in order to present an alert stating the error while loading an image
    @State private var errLoadingImagePresented : Bool = false
    
    /// Presents an alert stating an error has appeared in saving the database when set to true
    @State private var errSavingPresented : Bool = false
    
    @State private var imageDetailsPresented : Bool = false
    
    @State private var selectedImage : DB_Image?
    
    var body: some View {
        GeometryReader {
            metrics in
            List {
                //                if largeScreen {
                //                    Section {
                //                    } header: {
                //                        Image(systemName: dataStructure.iconName)
                //                            .resizable()
                //                            .scaledToFit()
                //                            .padding()
                //                    }
                //                }
                //            Section("Entries") {
                //                if !dataStructure.entries.isEmpty {
                //                    ForEach(dataStructure.entries) {
                //                        entry in
                //                        NavigationLink(entry.title) {
                //                            EntryDetails(entry: entry)
                //                        }
                //                    }
                //                } else {
                //                    Text("No Entries found")
                //                }
                //            }
                //            Section("Folder") {
                //                if !dataStructure.folders.isEmpty {
                //                    ForEach(dataStructure.folders) {
                //                        folder in
                //                        NavigationLink(folder.name) {
                //                            ME_ContentView(folder)
                //                        }
                //                    }
                //                } else {
                //                    Text("No Folders found")
                //                }
                //            }
                Section("Images") {
                    if !dataStructure.images.isEmpty {
                        if dataStructure.images.count <= 9 {
                            // TODO: maybe change ScrollView. Currently ScrollView and GroupBox havve the effect wanted
                            ScrollView {
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
                                    ForEach(dataStructure.images) {
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
                        } else {
                            NavigationLink {
                                EmptyView()
//                                ImageListDetails()
                            } label: {
                                Label("Show all images (\(dataStructure.images.count))", systemImage: "photo")
                            }
                        }
                    } else {
                        Text("No Images found")
                    }
                }
                //        Section("Documents") {
                //            if !dataStructure.documents.isEmpty {
                //                ForEach(dataStructure.documents) {
                //                    document in
                //                }
                //            } else {
                //                Text("No Documents found")
                //            }
                //        }
            }
        }
        .sheet(isPresented: $detailsPresented) {
            Me_Details(me: dataStructure)
        }
        .sheet(isPresented: $addEntryPresented) {
            EditEntry()
                .environmentObject(db)
        }
        .sheet(isPresented: $addFolderPresented) {
            EditFolder()
                .environmentObject(db)
        }
        .photosPicker(
            isPresented: $addImagePresented,
            selection: $photosSelected,
            maxSelectionCount: 1000,
            selectionBehavior: .continuousAndOrdered,
            matching: .images,
            preferredItemEncoding: .automatic
        )
        .sheet(isPresented: $addDocPresented) {
            // TODO: udpate
            EditEntry()
        }
        .sheet(isPresented: $imageDetailsPresented) {
            ImageDetails(image: $selectedImage)
        }
        .navigationTitle(dataStructure is Database ? "Home" : dataStructure.name)
        .navigationBarTitleDisplayMode(.automatic)
        .toolbarRole(.navigationStack)
        .toolbar(.automatic, for: .navigationBar)
        .toolbar {
            if dataStructure is Database {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        // TODO: add closing Database Code
                        withAnimation {
                            navigationController.openDatabaseToHome.toggle()
                        }
                    } label: {
                        Image(systemName: "lock")
                    }
                }
            }
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button {
                        addEntryPresented.toggle()
                    } label: {
                        Label("Add Entry", systemImage: "doc")
                    }
                    Button {
                        addFolderPresented.toggle()
                    } label: {
                        Label("Add Folder", systemImage: "folder")
                    }
                    Button {
                        addImagePresented.toggle()
                    } label: {
                        Label("Add Images", systemImage: "photo")
                    }
                    Button {
                        addDocPresented.toggle()
                    } label: {
                        Label("Add Document", systemImage: "doc.text")
                    }
                    Divider()
                    Button {
                        detailsPresented.toggle()
                    } label: {
                        Label("Details", systemImage: "info.circle")
                    }
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .onChange(of: addImagePresented) {
            // Guard to not call this code when opening the Picker
            guard !addImagePresented else { return }
            for photo in photosSelected {
                Task {
                    do {
                        let image : UIImage = try await photo.loadTransferable(type: DBSoleImage.self)!.image
                        db.images.append(
                            DB_Image(
                                image: image,
                                quality: 0.5,
                                created: Date.now,
                                lastEdited: Date.now
                            )
                        )
                        do {
                            try Storage.storeDatabase(db, context: context)
                        } catch {
                            errSavingPresented.toggle()
                        }
                    } catch {
                        errLoadingImagePresented.toggle()
                    }
                }
            }
            // Clear photosSelected to not add a Photo twice when new photos are added via picker
            photosSelected = []
        }
        .alert("Error loading Image", isPresented: $errLoadingImagePresented) {}
        .alert("Error saving Database", isPresented: $errSavingPresented) {
        } message: {
            Text("An Error arised saving the Database")
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

internal struct ME_ContentView_Previews: PreviewProvider {
    
    @StateObject private static var db : Database = Database.previewDB
    
    static var previews: some View {
        ME_ContentView(db)
    }
}

internal struct ME_ContentViewLargeScreen_Previews: PreviewProvider {
    
    @StateObject private static var db : Database = Database.previewDB
    
    static var previews: some View {
        ME_ContentView(db)
            .environment(\.largeScreen, true)
    }
}
