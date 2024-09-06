//
//  ME_ContentView.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 22.08.23.
//

import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

internal struct ME_ContentView : View {
    
    @Environment(\.managedObjectContext) private var context
    
    /// Controls the navigation flow, only necessary if this represents a Database
    @EnvironmentObject private var navigationController : AddDB_Navigation
    
    /// Whether the User activated the large Screen preference or not
    @Environment(\.largeScreen) private var largeScreen : Bool
    
    /// The Database used to store the complere Database Object itself when data is added to it
    @EnvironmentObject private var db : Database
    
    internal init(_ dataStructure : ME_DataStructure<String, Date, Folder, Entry, LoadableResource>) {
        self.dataStructure = dataStructure
    }
    
    /// The Data Structure which is displayed in this View
    @State private var dataStructure : ME_DataStructure<String, Date, Folder, Entry, LoadableResource>
    
    @State private var images : [DB_Image] = []
    
    @State private var videos : [DB_Video] = []
    
    @State private var documents : [DB_Document] = []
    
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
    
    /// The Photos and videos selected to add to the Password Safe
    @State private var audioVisualItemsSelected : [PhotosPickerItem] = []
    
    @State private var selectedDB_Images : [DB_Image] = []
    
    @State private var selectedDB_Videos : [DB_Video] = []
    
    /// Set to true in order to present an alert stating the error while loading an image
    @State private var errLoadingImagePresented : Bool = false
    
    /// Set to true in order to present an alert displaying an error while loading the video
    @State private var errLoadingVideoPresented : Bool = false
    
    /// Presents an alert stating an error has appeared in saving the database when set to true
    @State private var errSavingPresented : Bool = false
    
    @State private var imageDetailsPresented : Bool = false
    
    @State private var imageListDetailsShown : Bool = false
    
    @State private var entryDetailsPresented : Bool = false
    
    @State private var selectedEntry : Entry?
    
    @State private var selectedImage : DB_Image?
    
    // TODO: update
    @State private var imageDeleted : Bool = false
    
    @State private var documentDeleted : Bool = false
    
    @State private var errLoadingDocumentPresented : Bool = false
    
    @State private var selectedDocument : DB_Document?
    
    @State private var textDocumentShown : Bool = false
    
    @State private var pdfDocumentShown : Bool = false
    
    private func loadRessources() -> Void {
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
            // TODO: handle error
        }
    }
    
    var body: some View {
        GeometryReader {
            metrics in
            List {
                largeScreenOption()
                entrySection()
                folderSection()
                imageSection(metrics)
                documentSection()
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
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .onAppear {
            loadRessources()
        }
        .sheet(isPresented: $detailsPresented) {
            Me_Details(me: dataStructure)
        }
        .alert("Error loading Image", isPresented: $errLoadingImagePresented) {}
        .alert("Error loading Video", isPresented: $errLoadingVideoPresented) {}
        .alert("Error loading Document", isPresented: $errLoadingDocumentPresented) {}
        .alert("Error saving Database", isPresented: $errSavingPresented) {
        } message: {
            Text("An Error arised saving the Database")
        }
    }
    
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
                }
            } else {
                Text("No Entries found")
            }
        }
        .sheet(isPresented: $entryDetailsPresented) {
            EntryDetails(entry: $selectedEntry)
        }
        .sheet(isPresented: $addEntryPresented) {
            EditEntry(folder: dataStructure is Folder ? dataStructure as? Folder : nil)
                .environmentObject(db)
        }
    }
    
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
                }
            } else {
                Text("No Folders found")
            }
        }
        .sheet(isPresented: $addFolderPresented) {
            EditFolder()
                .environmentObject(db)
        }
    }
    
    @ViewBuilder
    private func imageSection(_ metrics : GeometryProxy) -> some View {
        Section("Images") {
            if !images.isEmpty {
                if images.count <= 9 {
                    // TODO: maybe change ScrollView. Currently ScrollView and GroupBox have the effect wanted
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
                } else {
                    NavigationLink {
                        ImageListDetails(images: $images, videos: $videos)
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
        .sheet(isPresented: $imageDetailsPresented) {
            ImageDetails(image: $selectedImage, deleted: $imageDeleted)
        }
        .photosPicker(
            isPresented: $addImagePresented,
            selection: $audioVisualItemsSelected,
            maxSelectionCount: 100,
            selectionBehavior: .continuousAndOrdered,
            matching: .any(of: [.images, .videos]),
            preferredItemEncoding: .automatic
        )
        .onChange(of: addImagePresented) {
            Task {
                do {
                    try await PhotoPickerHandler.handlePhotoPickerInput(
                        items: audioVisualItemsSelected,
                        pickerPresented: addImagePresented,
                        images: $images,
                        videos: $videos,
                        storeIn: db,
                        with: context
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
    
    @ViewBuilder
    private func documentSection() -> some View {
        Section("Documents") {
            if !documents.isEmpty {
                ForEach(documents) {
                    document in
                    Button {
                        selectedDocument = document
                        if document.isText() {
                            textDocumentShown.toggle()
                        } else if document.isPDF() {
                            pdfDocumentShown.toggle()
                        }
                    } label: {
                        Label(document.name, systemImage: "doc")
                    }
                    .foregroundStyle(.primary)
                }
                .sheet(isPresented: $textDocumentShown) {
                    NavigationStack {
                        // TODO: update with Binding
                        Text(DataConverter.dataToString(selectedDocument?.document ?? Data()))
                    }
                }
                .sheet(isPresented: $pdfDocumentShown) {
                    PDFDocumentDetails(pdfDocument: $selectedDocument, delete: $documentDeleted)
                }
            } else {
                Text("No Documents found")
            }
        }
        .fileImporter(
            isPresented: $addDocPresented,
            allowedContentTypes: [.item],
            allowsMultipleSelection: true
        ) {
            result in
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
                                    type: file.pathExtension,
                                    name: file.lastPathComponent,
                                    created: Date.now,
                                    lastEdited: Date.now,
                                    id: UUID()
                                )
                            )
                        } catch {
                            errLoadingDocumentPresented.toggle()
                        }
                        file.stopAccessingSecurityScopedResource()
                    }
                    self.documents.append(contentsOf: documents)
                case .failure:
                    errLoadingDocumentPresented.toggle()
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
