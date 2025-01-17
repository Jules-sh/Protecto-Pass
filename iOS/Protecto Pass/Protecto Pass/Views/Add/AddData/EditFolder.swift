//
//  EditFolder.swift
//  Protecto Pass
//
//  Created by Julian Schumacher as AddFolder.swift on 28.07.23.
//
//  Renamed by Julian Schumacher to EditFolder.swift on 26.08.23.
//

import SwiftUI

/// A Screen to create a new Folder which then
/// is added to the Database
internal struct EditFolder: View {
    
    @Environment(\.managedObjectContext) private var context
    
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject private var db : Database
    
    /// The name of the Folder
    @State private var name : String = ""
    
    @State private var description : String = ""
    
    /// The parent folder of this Folder
    @State private var superFolder : Folder?
    
    @State private var storeInFolder : Bool = false
    
    @State private var errStoring : Bool = false
    
    @State private var iconName : String = "folder"
    
    @State private var iconChooserShown : Bool = false
    
    @State private var folder : Folder? = nil
    
    internal init(
        storeIn superFolder : Folder? = nil,
        folder : Folder? = nil
    ) {
        storeInFolder = (superFolder != nil)
        self.superFolder = superFolder
        if let f = folder {
            self.folder = f
            name = f.name
            description = f.description
            iconName = f.iconName
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section("Representation") {
                    Button {
                        iconChooserShown.toggle()
                    } label: {
                        Label("Icon", systemImage: iconName)
                    }
                    .foregroundStyle(.primary)
                }
                .sheet(isPresented: $iconChooserShown) {
                    IconChooser(iconName: $iconName, type: .folder)
                }
                Section("Information") {
                    TextField("Name", text: $name)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...10)
                }
                Section("Storing") {
                    Toggle(isOn: $storeInFolder.animation()) {
                        Label("Store in Folder", systemImage: "folder")
                            .foregroundStyle(.primary)
                    }
                    if storeInFolder {
                        Picker("Folder", selection: $superFolder) {
                            if (db.folders.isEmpty) {
                                Text("No folder available")
                            } else {
                                ForEach(db.folders) {
                                    folder in
                                    Text(folder.name)
                                }
                            }
                        }
                        .disabled(db.folders.isEmpty)
                    }
                }
            }
            //            VStack {
            //                Button {
            //                    iconChooserShown.toggle()
            //                } label: {
            //                    Image(systemName: iconName)
            //                        .renderingMode(.original)
            //                        .symbolRenderingMode(.hierarchical)
            //                        .resizable()
            //                        .scaledToFit()
            //                        .padding(.horizontal, 75)
            //                        .foregroundStyle(.foreground)
            //                }
            //                .sheet(isPresented: $iconChooserShown) {
            //                    IconChooser(iconName: $iconName, type: .folder)
            //                }
            //                Group {
            //                    TextField("Name", text: $name)
            //                        .textInputAutocapitalization(.words)
            //                        .textFieldStyle(.roundedBorder)
            //                        .padding(.top, 40)
            //                    TextField("Description", text: $description, axis: .vertical)
            //                        .textInputAutocapitalization(.sentences)
            //                        .textFieldStyle(.roundedBorder)
            //                        .lineLimit(3...10)
            //                }
            //                Group {
            //                    // TODO: update group content
            //                    Toggle(isOn: $storeInFolder.animation()) {
            //                        Label("Store in Folder", systemImage: "folder")
            //                    }
            //                    if storeInFolder {
            //                        Picker("Folder", selection: $folder) {
            //                            if (db.folders.isEmpty) {
            //                                Text("No folder available")
            //                            } else {
            //                                ForEach(db.folders) {
            //                                    folder in
            //                                    Text(folder.name)
            //                                }
            //                            }
            //                        }
            //                        .disabled(db.folders.isEmpty)
            //                        .pickerStyle(.menu)
            //                    }
            //                }
            //            }
            .alert("Error saving", isPresented: $errStoring) {
                Button("Cancel", role: .cancel) {}
                Button("Try again") { save() }
            } message: {
                Text("An Error occurred when trying to save the data.\nPlease try again")
            }
            //            .padding(.horizontal, 25)
            .navigationTitle("New Folder")
            .navigationBarTitleDisplayMode(.automatic)
            .toolbarRole(.editor)
            .toolbar(.automatic, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        save()
                    }
                }
            }
        }
    }
    
    /// Saves the Data and dismisses this View
    private func save() -> Void {
        do {
            try Storage.storeDatabase(
                db,
                context: context,
                newElements: [
                    Folder(
                        name: name,
                        description: description,
                        folders: folder?.folders ?? [],
                        entries: folder?.entries ?? [],
                        images: folder?.images ?? [],
                        videos: folder?.videos ?? [],
                        iconName: iconName,
                        documents: folder?.documents ?? [],
                        created: folder?.created ?? Date.now,
                        lastEdited: Date.now,
                        id: folder?.id ?? UUID()
                    )
                ]
            )
            dismiss()
        } catch {
            errStoring.toggle()
        }
    }
}

internal struct EditFolder_Previews: PreviewProvider {
    
    @StateObject private static var database : Database = Database.previewDB
    
    static var previews: some View {
        EditFolder()
            .environmentObject(database)
    }
}
