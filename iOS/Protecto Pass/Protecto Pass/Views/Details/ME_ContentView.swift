//
//  ME_ContentView.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 22.08.23.
//

import SwiftUI

internal struct ME_ContentView : View {

    /// Controls the navigation flow, only necessary if this represents a Database
    @EnvironmentObject private var navigationController : AddDB_Navigation

    /// Whether the User activated the large Screen preference or not
    @Environment(\.largeScreen) private var largeScreen : Bool
    
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
    
    var body: some View {
        List {
            if largeScreen {
                Section {
                } header: {
                    Image(systemName: dataStructure.iconName)
                        .resizable()
                        .scaledToFit()
                        .padding()
                }
            }
            Section("Entries") {
                if !dataStructure.entries.isEmpty {
                    ForEach(dataStructure.entries) {
                        entry in
                        NavigationLink(entry.title) {
                            EntryDetails(entry: entry)
                        }
                    }
                } else {
                    Text("No Entries found")
                }
            }
            Section("Folder") {
                if !dataStructure.folders.isEmpty {
                    ForEach(dataStructure.folders) {
                        folder in
                        NavigationLink(folder.name) {
                            ME_ContentView(folder)
                        }
                    }
                } else {
                    Text("No Folders found")
                }
            }
            Section("Images") {
                if !dataStructure.images.isEmpty {
                    ForEach(dataStructure.images) {
                        image in
                    }
                } else {
                    Text("No Images found")
                }
            }
            Section("Documents") {
                if !dataStructure.documents.isEmpty {
                    ForEach(dataStructure.documents) {
                        document in
                    }
                } else {
                    Text("No Documents found")
                }
            }
        }
        .sheet(isPresented: $detailsPresented) {
            Me_Details(me: dataStructure)
        }
        .sheet(isPresented: $addEntryPresented) {
            EditEntry()
        }
        .sheet(isPresented: $addFolderPresented) {
            EditFolder()
        }
        .sheet(isPresented: $addImagePresented) {
            // TODO: udpate
            EditEntry()
        }
        .sheet(isPresented: $addDocPresented) {
            // TODO: udpate
            EditEntry()
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
                        Label("Add Image", systemImage: "photo")
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
