//
//  ME_ContentViewEntrySection.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 22.09.24.
//

import SwiftUI

internal struct ME_ContentViewEntrySection: View {
    
    @Environment(\.managedObjectContext) private var context
    
    @EnvironmentObject private var db : Database
    
    @ObservedObject private var dataStructure : ME_DataStructure<String, Date, Folder, Entry, LoadableResource>
    
    @State private var selectedEntry : Entry?
    
    @State private var entryDetailsPresented : Bool = false
    
    internal init(
        dataStructure : ME_DataStructure<String, Date, Folder, Entry, LoadableResource>
    ) {
        self.dataStructure = dataStructure
    }
    
    @State private var entryDeletionConfirmationShown : Bool = false
    
    @State private var errDeletionShown : Bool = false
    
    var body: some View {
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
                    .alert("Delete Entry?", isPresented: $entryDeletionConfirmationShown) {
                        Button("Continue", role: .destructive) {
                            do {
                                dataStructure.entries.removeAll(where: { $0.id == selectedEntry!.id })
                                try Storage.storeDatabase(db, context: context, superID: dataStructure.id)
                            } catch {
                                dataStructure.entries.append(selectedEntry!)
                                errDeletionShown.toggle()
                            }
                        }
                        Button("Cancel", role: .cancel) {
                            entryDeletionConfirmationShown.toggle()
                        }
                    } message: {
                        Text("This Entry and all it's connected documents will be deleted\nThis action is irreversible")
                    }
                    .alert("Error deleting Entry", isPresented: $errDeletionShown) {
                    } message: {
                        Text("There's been an error deleting the selected Entry")
                    }
                    // TODO: does not work on Button either
                    .sheet(isPresented: $entryDetailsPresented) {
                        EntryDetails(entry: $selectedEntry)
                    }
                }
            } else {
                Text("No Entries found")
            }
        }
    }
}

#Preview {
    
    @Previewable @State var dataStructure : ME_DataStructure<String, Date, Folder, Entry, LoadableResource> = Database.previewDB
    
    @Previewable @State var addEntryPresented : Bool = false
    
    List {
        ME_ContentViewEntrySection(dataStructure: dataStructure)
    }
}
