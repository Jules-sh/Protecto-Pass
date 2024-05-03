//
//  ME_Details.swift
//  Protecto Pass
//
//  Created by Julian Schumacher as FolderDetails.swift on 28.07.23.
//
//  Renamed by Julian Schumacher to ME_Details.swift on 22.08.23.
//

import SwiftUI

internal struct Me_Details: View {

    @Environment(\.dismiss) private var dismiss
    
    internal let me : ME_DataStructure<String, Date>
    
    var body: some View {
        NavigationStack {
            List {
                Section("General") {
                    ListTile(name: "Name", data: me.name)
                    if me.description.isEmpty {
                        ListTile(name: "Description", data: "No Description provided")
                    } else {
                        Group {
                            Text("Description")
                            Text(me.description)
                                .foregroundColor(.gray)
                        }
                    }
                }
                Section("Content") {
                    // TODO: Add Content Information
                }
                Section("Timeline") {
                    ListTile(name: "Created", date: me.created)
                    ListTile(name: "Last edited", date: me.lastEdited)
                }
            }
            .navigationTitle("Details")
            .navigationBarTitleDisplayMode(.automatic)
            .toolbarRole(.navigationStack)
            .toolbar(.automatic, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) {
                        dismiss()
                    }
                }
            }
        }
    }
}

internal struct ME_Details_Previews: PreviewProvider {
    static var previews: some View {
        Me_Details(me: Folder.previewFolder)
    }
}
