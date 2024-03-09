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
    
    /// The Database used to store the complere Database Object itself when data is added to it
    @EnvironmentObject private var db : Database
    
    private let id : UUID
    
    internal init(id : UUID) {
        self.id = id
        dataStructure = nil
    }
    
    /// The Data Structure which is displayed in this View
    @State private var dataStructure : ME_DataStructure<String, Date, UUID>?
    
    private var images : [DB_Image] = []
    
    private var documents : [DB_Document] = []
    
    private var entries : [Entry] = []
    
    private var folders : [Folder] = []
    
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
    
    @State private var selectedDB_Images : [DB_Image] = []
    
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
                    if !images.isEmpty {
                        if images.count <= 9 {
                            // TODO: maybe change ScrollView. Currently ScrollView and GroupBox havve the effect wanted
                            //                            ScrollView {
                            //                                LazyVGrid(
                            //                                    columns: [
                            //                                        GridItem(
                            //                                            .fixed(metrics.size.width / 3),
                            //                                            spacing: 2
                            //                                        ),
                            //                                        GridItem(
                            //                                            .fixed(metrics.size.width / 3),
                            //                                            spacing: 2
                            //                                        ),
                            //                                        GridItem(
                            //                                            .fixed(metrics.size.width / 3),
                            //                                            spacing: 2
                            //                                        ),
                            //                                    ],
                            //                                    spacing: 2
                            //                                ) {
                            //                                    ForEach(dataStructure.images) {
                            //                                        image in
                            //                                        Button {
                            //                                            selectedImage = image
                            //                                            imageDetailsPresented.toggle()
                            //                                        } label: {
                            //                                            Image(uiImage: image.image)
                            //                                                .resizable()
                            //                                                .frame(
                            //                                                    width: metrics.size.width / 3,
                            //                                                    height: metrics.size.width / 3
                            //                                                )
                            //                                        }
                            //                                    }
                            //                                }
                            //                            }
                        } else {
                            NavigationLink {
                                ImageListDetails()
                                    .environmentObject(dataStructure!)
                            } label: {
                                Label("Show all images (\(images.count))", systemImage: "photo")
                            }
                        }
                    } else {
                        Text("No Images found")
                    }
                }
                //        Section("Documents") {
                //            if !documents.isEmpty {
                //                ForEach(documents) {
                //                    document in
                //                }
                //            } else {
                //                Text("No Documents found")
                //            }
                //        }
            }
        }
        .sheet(isPresented: $detailsPresented) {
            Me_Details(me: dataStructure!)
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
        // Shows "Home" when the Data Structure is a Database, otherwise shows the title of the data structure. While the data structure is nil, such as while the app is loading, it showns "Loading..."
        .navigationTitle(dataStructure is Database ? "Home" : dataStructure?.name ?? "Loading...")
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
            Task {
                for photo in photosSelected {
                    do {
                        let image : UIImage = try await photo.loadTransferable(type: DBSoleImage.self)!.image
                        let uuid : UUID = UUID()
                        selectedDB_Images.append(
                            DB_Image(
                                image: image,
                                quality: 0.5,
                                created: Date.now,
                                lastEdited: Date.now,
                                id: uuid
                            )
                        )
                        db.contents.append(
                            ToCItem(
                                // TODO: change itemIdentifier
                                name: photo.itemIdentifier!,
                                type: .image,
                                id: uuid,
                                children: []
                            )
                        )
                    } catch {
                        errLoadingImagePresented.toggle()
                    }
                }
                do {
                    try Storage.storeDatabase(db, context: context)
                } catch {
                    errSavingPresented.toggle()
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
        .onAppear {
            // Environment Object can't be used in init, so method is called on appear of view
            // https://www.hackingwithswift.com/forums/swiftui/environmentobject-usage-in-init-of-a-view/5795
            loadStructure()
        }
    }
    
    /// Loads the structure needed
    private func loadStructure() -> Void {
        if id == db.id {
            dataStructure = db
        } else {
            // Passed Data structure is a folder
            // TODO: add Code in order to load Folder
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
        ME_ContentView(id: db.id)
            .environmentObject(db)
    }
}

internal struct ME_ContentViewLargeScreen_Previews: PreviewProvider {
    
    @StateObject private static var db : Database = Database.previewDB
    
    static var previews: some View {
        ME_ContentView(id: db.id)
            .environmentObject(db)
            .environment(\.largeScreen, true)
    }
}
