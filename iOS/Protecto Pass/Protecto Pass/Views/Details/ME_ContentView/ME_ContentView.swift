//
//  ME_ContentView.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 22.08.23.
//

import SwiftUI
import PhotosUI

internal struct ME_ContentView : View {
    
    /* ENVIRONMENT VARIABLES */
    
    @Environment(\.managedObjectContext) private var context
    
    /// Whether the User activated the large Screen preference or not
    @Environment(\.largeScreen) private var largeScreen : Bool
    
    // Environment Objects
    
    /// Controls the navigation flow, only necessary if this represents a Database
    @EnvironmentObject private var navigationController : AddDB_Navigation
    
    /// The Database used to store the complete Database Object itself when data is added to it
    @EnvironmentObject private var db : Database
    
    
    internal init(_ dataStructure : ME_DataStructure<String, Date, Folder, Entry, LoadableResource>) {
        self.dataStructure = dataStructure
    }
    
    
    
    /* DATA VARIABLES */
    
    /// The Data Structure which is displayed in this View
    @State private var dataStructure : ME_DataStructure<String, Date, Folder, Entry, LoadableResource>
    
    /// All the Images shown and stored in this view
    @State private var images : [DB_Image] = []
    
    /// All the videos shown and stored in this view
    @State private var videos : [DB_Video] = []
    
    /// All the documents shown and stored in this view
    @State private var documents : [DB_Document] = []
    
    
    
    /* SHEET CONTROL VARIABLES */
    
    // Adding
    
    /// Whether or not the sheet to add an entry is presented
    @State private var addEntryPresented : Bool = false
    
    /// Whether or not the sheet to add a folder is presented
    @State private var addFolderPresented : Bool = false
    
    /// Whether or not the sheet to add an image is presented
    @State private var addImagePresented : Bool = false
    
    /// Whether or not the sheet to add a document is presented
    @State private var addDocPresented : Bool = false
    
    // Details
    
    /// Whether or not the details sheet is presented
    @State private var detailsPresented : Bool = false
    
    /// Whether or not the details sheet for an image is presented
    @State private var imageDetailsPresented : Bool = false
    
    /// Whether or not the details sheet for an entry is presented
    @State private var entryDetailsPresented : Bool = false
    
    /// Whether or not the sheet displaying a Document is shown
    @State private var documentShown : Bool = false
    
    
    
    /* ERROR ALERT CONTROL VARIABLES */
    
    // Loading
    
    /// Set to true in order to present an alert stating the error while loading an image
    @State private var errLoadingImagePresented : Bool = false
    
    /// Set to true in order to present an alert displaying an error while loading the video
    @State private var errLoadingVideoPresented : Bool = false
    
    /// Set to true in order to present an alert displaying an error while loading the document
    @State private var errLoadingDocumentPresented : Bool = false
    
    /// Displays an alert displaying an error while loading resources
    @State private var errLoadingResourcesShown : Bool = false
    
    // Saving
    
    /// Presents an alert stating an error has appeared in saving the database when set to true
    @State private var errSavingPresented : Bool = false
    
    // Deleting
    
    /// Setting this to true will result in displaying an error alert which states, there's been an error deleting
    /// the 'selectedType'
    @State private var errDeletingShown : Bool = false
    
    
    /* DIALOG ALERT CONTROL VARIABLES */
    
    @State private var entryDeletionConfirmationShown : Bool = false
    
    @State private var folderDeletionConfiramtionShown : Bool = false
    
    @State private var imageDeletionConfirmationShown : Bool = false
    
    @State private var videoDeletionConfirmationShown : Bool = false
    
    @State private var documentDeletionConfirmationShown : Bool = false
    
    
    
    /* SELECTED DATA VARIABLES */
    
    /// The Photos and videos selected to add to the Password Safe
    @State private var audioVisualItemsSelected : [PhotosPickerItem] = []
    
    /// The entry selected to display in the EntryDetails sheet
    @State private var selectedEntry : Entry?
    
    @State private var selectedFolder : Folder?
    
    /// The image selected to display in the sheet
    @State private var selectedImage : DB_Image?
    
    @State private var selectedVideo : DB_Video?
    
    /// The document selected to display in the according view
    @State private var selectedDocument : DB_Document?
    
    @State private var selectedType : SelectedType?
    
    
    /// Loads the resources, such as images, videos and documents, and stores them in the
    /// corresponding arrays
    private func loadResources() -> Void {
        var imageIDs : [UUID] = []
        var videoIDs : [UUID] = []
        var documentIDs : [UUID] = []
        dataStructure.images.forEach({ imageIDs.append($0.id) })
        dataStructure.videos.forEach({ videoIDs.append($0.id) })
        dataStructure.documents.forEach({ documentIDs.append($0.id) })
        do {
            images = try Storage.loadImages(db, ids: imageIDs, context: context)
            videos = try Storage.loadVideos(db, ids: videoIDs, context: context)
            documents = try Storage.loadDocuments(db, ids: documentIDs, context: context)
        } catch {
            errLoadingResourcesShown.toggle()
        }
    }
    
    var body: some View {
        GeometryReader {
            metrics in
            List {
                largeScreenOption()
                ME_ContentViewEntrySection(
                    dataStructure: $dataStructure,
                    selectedEntry: $selectedEntry,
                    entryDetailsPresented: $entryDetailsPresented
                )
                entrySection()
                folderSection()
                    .alert("Delete Folder?", isPresented: $folderDeletionConfiramtionShown) {
                        Button("Continue", role: .destructive) {
                            do {
                                dataStructure.folders.removeAll(where: { $0.id == selectedFolder!.id })
                                try Storage.storeDatabase(db, context: context, superID: dataStructure.id)
                            } catch {
                                dataStructure.entries.append(selectedFolder!)
                                selectedType = .folder
                                errDeletingShown = true
                            }
                        }
                        Button("Cancel", role: .cancel) {
                            folderDeletionConfiramtionShown.toggle()
                        }
                    } message: {
                        Text("This Folder and all it's content will be deleted\nThis action is irreversible")
                    }
                imageSection(metrics)
                    .alert("Error loading Image", isPresented: $errLoadingImagePresented) {
                    } message: {
                        Text("There's been an error while trying to load this image")
                    }
                    .alert("Error loading Video", isPresented: $errLoadingVideoPresented) {
                    } message: {
                        Text("There's been an error while trying to load this video")
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
                                selectedType = .image
                                errDeletingShown = true
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
                                selectedType = .video
                                errDeletingShown = true
                            }
                        }
                        Button("Cancel", role: .cancel) {
                            videoDeletionConfirmationShown.toggle()
                        }
                    } message: {
                        Text("This Video will be deleted\nThis action is irreversible")
                    }
                documentSection()
                    .alert("Error loading Document", isPresented: $errLoadingDocumentPresented) {
                    } message: {
                        Text("There's been an error while trying to load this document")
                    }
                    .alert("Delete Document?", isPresented: $documentDeletionConfirmationShown) {
                        Button("Continue", role: .destructive) {
                            let loadableResource : LoadableResource = dataStructure.documents.first(where: { $0.id == selectedDocument!.id })!
                            do {
                                documents.removeAll(where: { $0.id == selectedDocument!.id })
                                dataStructure.documents.removeAll(where: { $0.id == selectedDocument!.id })
                                try Storage.deleteDocument(id: selectedDocument!.id, in: db, with: context)
                            } catch {
                                documents.append(selectedVideo!)
                                dataStructure.documents.append(loadableResource)
                                selectedType = .document
                                errDeletingShown.toggle()
                            }
                        }
                        Button("Cancel", role: .cancel) {
                            documentDeletionConfirmationShown.toggle()
                        }
                    } message: {
                        Text("This Document will be deleted\nThis action is irreversible")
                    }
            }
        }
        // Shows "Home" when the Data Structure is a Database, otherwise shows the title of the data structure. While the data structure is nil, such as while the app is loading, it showns "Loading..."
        .navigationTitle(dataStructure is Database ? "Home" : dataStructure.name)
        .navigationBarTitleDisplayMode(.automatic)
        .toolbarRole(.navigationStack)
        .toolbar(.automatic, for: .navigationBar)
        .toolbar {
            if dataStructure is Database {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        // TODO: add closing Database Code
                        navigationController.db = nil
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
                        Label("Add Images & Videos", systemImage: "photo")
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
                    Divider()
                    Button {
                        // Activate Edit mode
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .onAppear {
            loadResources()
        }
        // Detail sheets
        .sheet(isPresented: $detailsPresented) {
            Me_Details(me: dataStructure)
        }
        // https://stackoverflow.com/questions/67180982/swiftui-presentation-attempt-to-present-view-on-which-is-already-present
        // https://stackoverflow.com/a/78309451
        // Do not present sheet on Section
        .sheet(isPresented: $imageDetailsPresented) {
            ImageDetails(image: $selectedImage, deleted: $imageDeletionConfirmationShown)
        }
        .sheet(isPresented: $documentShown) {
            DocumentDetails(document: $selectedDocument, delete: $documentDeletionConfirmationShown)
        }
        // Edit sheets
        .sheet(isPresented: $addEntryPresented) {
            EditEntry(superID: dataStructure.id)
                .environmentObject(db)
        }
        .sheet(isPresented: $addFolderPresented) {
            EditFolder(storeIn: dataStructure.id)
                .environmentObject(db)
        }
        .photosPicker(
            isPresented: $addImagePresented,
            selection: $audioVisualItemsSelected,
            maxSelectionCount: 100,
            selectionBehavior: .continuousAndOrdered,
            matching: .any(of: [.images, .videos]),
            preferredItemEncoding: .automatic
        )
        .fileImporter(
            isPresented: $addDocPresented,
            allowedContentTypes: [.item],
            allowsMultipleSelection: true,
            onCompletion: {
                result in
                Task {
                    do {
                        try FileImportHandler.handleDocumentPickerInput(
                            result: result,
                            documents: $documents,
                            storeIn: db,
                            context: context,
                            onSuperID: dataStructure.id
                        )
                    } catch is DocumentLoadingError {
                        errLoadingDocumentPresented.toggle()
                    } catch is DocumentSavingError {
                        errSavingPresented.toggle()
                    }
                }
            }
        )
        // loading error alerts
        .alert("Error saving Database", isPresented: $errSavingPresented) {
        } message: {
            Text("An Error arised saving the Database to the file system")
        }
        .alert("Error loading resources", isPresented: $errLoadingResourcesShown) {
        } message: {
            Text("There's been an error while trying to load the resources from the file system")
        }
        // deletion error alerts
        .alert("Error deleting \(selectedType?.rawValue ?? "unknown type")", isPresented: $errDeletingShown) {
            // No actions
        } message: {
            Text("An error occured while deleting \(selectedType?.rawValue ?? "unknown type")")
        }
    }
    
    /// Represents the Type currently selected for i.e. deletion
    private enum SelectedType : String, RawRepresentable {
        case entry
        case folder
        case image
        case video
        case document
    }
    
    /// Builds the header displayed when using large screen mode
    @ViewBuilder
    private func largeScreenOption() -> some View {
        if largeScreen {
            Section {
            } header: {
                Image(systemName: dataStructure.iconName)
                    .resizable()
                    .scaledToFit()
                    .padding()
            }
        }
    }
    
    /// Builds the section that displays entries in this view
    @ViewBuilder
    private func entrySection() -> some View {
        Section("Entries") {
            if !dataStructure.entries.isEmpty {
                ForEach(dataStructure.entries) {
                    entry in
                    Button {
                        selectedEntry = entry
                        entryDetailsPresented.toggle()
                    } label: {
                        Label(entry.title, systemImage: entry.iconName)
                    }
                    .foregroundStyle(.primary)
                    .contextMenu {
                        Button(role: .destructive) {
                            selectedEntry = entry
                            entryDeletionConfirmationShown.toggle()
                        } label: {
                            Label("Delete Entry", systemImage: "trash")
                        }
                    }
                }
            } else {
                Text("No Entries found")
            }
        }
    }
    
    /// Builds the section that displays folders and enables the user
    /// to navigate to the new folder
    @ViewBuilder
    private func folderSection() -> some View {
        Section("Folder") {
            if !dataStructure.folders.isEmpty {
                ForEach(dataStructure.folders) {
                    folder in
                    NavigationLink {
                        ME_ContentView(folder)
                            .environmentObject(db)
                    } label: {
                        Label(folder.name, systemImage: folder.iconName)
                    }
                    .foregroundStyle(.primary)
                    .contextMenu {
                        Button(role: .destructive) {
                            selectedFolder = folder
                            folderDeletionConfiramtionShown.toggle()
                        } label: {
                            Label("Delete Folder", systemImage: "trash")
                        }
                    }
                }
            } else {
                Text("No Folders found")
            }
        }
    }
    
    /// Builds the section that displays either up to nine images or
    /// the navigationlink to the ImageListDetails
    @ViewBuilder
    private func imageSection(_ metrics : GeometryProxy) -> some View {
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
        .onChange(of: addImagePresented) {
            Task {
                do {
                    try await PhotoPickerHandler.handlePhotoPickerInput(
                        items: audioVisualItemsSelected,
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
                    errSavingPresented.toggle()
                }
            }
        }
    }
    
    /// Builds the section displaying a list of documents stored in this data structure
    @ViewBuilder
    private func documentSection() -> some View {
        Section("Documents") {
            if !documents.isEmpty {
                ForEach(documents) {
                    document in
                    Button {
                        selectedDocument = document
                        if document.canBeViewed() {
                            documentShown.toggle()
                        }
                    } label: {
                        Label(document.name, systemImage: "doc")
                    }
                    .foregroundStyle(.primary)
                    .contextMenu {
                        Button(role: .destructive) {
                            selectedDocument = document
                            documentDeletionConfirmationShown.toggle()
                        } label: {
                            Label("Delete Document", systemImage: "trash")
                        }
                    }
                }
            } else {
                Text("No Documents found")
            }
        }
    }
}


internal struct ME_ContentView_Previews: PreviewProvider {
    
    @StateObject private static var db : Database = Database.previewDB
    
    static var previews: some View {
        ME_ContentView(db)
            .environmentObject(db)
    }
}

internal struct ME_ContentViewLargeScreen_Previews: PreviewProvider {
    
    @StateObject private static var db : Database = Database.previewDB
    
    static var previews: some View {
        ME_ContentView(db)
            .environmentObject(db)
            .environment(\.largeScreen, true)
    }
}
