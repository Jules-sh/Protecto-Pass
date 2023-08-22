//
//  ME_ContentView.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 22.08.23.
//

import SwiftUI

internal struct ME_ContentView : View {
    
    internal init(_ data : ME_DataStructure<String, Folder, Entry>) {
        dataStructure = data
    }
    
    private let dataStructure : ME_DataStructure<String, Folder, Entry>
    
    var body: some View {
        List {
            Section("Entries") {
                ForEach(dataStructure.entries) {
                    entry in
                    NavigationLink(entry.title) {
                        EntryDetails(entry: entry)
                    }
                }
            }
            Section("Folder") {
                ForEach(dataStructure.folders) {
                    folder in
                    NavigationLink(folder.name) {
                        ME_ContentView(folder)
                    }
                }
            }
        }
        .navigationTitle(dataStructure is Database ? "Home" : dataStructure.name)
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
                    Divider()
                    NavigationLink {
                        Me_Details(me: dataStructure)
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
            .environmentObject(db)
    }
}
