//
//  ME_ContentViewFolderSection.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 24.09.24.
//

import SwiftUI

internal struct ME_ContentViewFolderSection: View {
    
    @Environment(\.managedObjectContext) private var context
    
    @EnvironmentObject private var db : Database
    
    @ObservedObject private var dataStructure : ME_DataStructure<String, Date, Folder, Entry, LoadableResource>
    
    internal init(
        dataStructure : ME_DataStructure<String, Date, Folder, Entry, LoadableResource>
    ) {
        self.dataStructure = dataStructure
    }
    
    @State private var selectedFolder : Folder?
    
    @State private var folderDeletionConfiramtionShown : Bool = false
    
    @State private var errDeletionShown : Bool = false
    
    var body: some View {
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
                    .alert("Delete Folder?", isPresented: $folderDeletionConfiramtionShown) {
                        Button("Continue", role: .destructive) {
                            do {
                                dataStructure.folders.removeAll(where: { $0.id == selectedFolder!.id })
                                try Storage.storeDatabase(db, context: context, superID: dataStructure.id)
                            } catch {
                                dataStructure.folders.append(selectedFolder!)
                                errDeletionShown.toggle()
                            }
                        }
                        Button("Cancel", role: .cancel) {
                            folderDeletionConfiramtionShown.toggle()
                        }
                    } message: {
                        Text("This Folder and all it's content will be deleted\nThis action is irreversible")
                    }
                    .alert("Error deleting Folder", isPresented: $errDeletionShown) {
                    } message: {
                        Text("There's been an error deleting the selected Folder")
                    }
                }
            } else {
                Text("No Folders found")
            }
        }
    }
}

#Preview {
    
    @Previewable @State var dataStructure : ME_DataStructure<String, Date, Folder, Entry, LoadableResource> = Database.previewDB
    
    List {
        ME_ContentViewFolderSection(dataStructure: dataStructure)
    }
}
