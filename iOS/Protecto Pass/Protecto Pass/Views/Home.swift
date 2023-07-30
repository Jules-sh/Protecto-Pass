//
//  Home.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 27.05.23.
//

import SwiftUI

/// The Home View, containing the unlocked
/// Database
internal struct Home: View {
    
    /// The Database that the User has just unlocked
    @StateObject internal var db : Database
    
    /// Whether the Popover on the action button is presented or not
    @State private var addPopoverPresented : Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                Section("Entries") {
                    ForEach(db.entries) {
                        entry in
                        NavigationLink(entry.title) {
                            EntryDetails(entry: entry)
                        }
                    }
                }
                Section("Folder") {
                    ForEach(db.folders) {
                        folder in
                        NavigationLink(folder.name) {
                            FolderDetails(folder: folder)
                        }
                    }
                }
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.automatic)
            .toolbarRole(.navigationStack)
            .toolbar(.automatic, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        NavigationLink {
                            AddEntry()
                        } label: {
                            Label("Add Entry", systemImage: "doc")
                        }
                        NavigationLink {
                            AddFolder()
                        } label: {
                            Label("Add Folder", systemImage: "folder")
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
}

/// The Preview for the Home View
internal struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home(db: Database.previewDB)
    }
}
