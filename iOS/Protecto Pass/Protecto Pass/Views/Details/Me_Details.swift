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
    
    internal let me : ME_DataStructure<String, Folder, Entry, String, Date, [Data]>
    
    var body: some View {
        List {
            Section {
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
            } header: {
                Text("General")
            }
            Section {
                Text("Contains \(me.folders.count) Folders")
                Text("Contains \(me.entries.count) Entries")
            } header: {
                Text("Content")
            }
        }
        .navigationTitle("\(me.name) Details")
        .navigationBarTitleDisplayMode(.automatic)
    }
}

internal struct ME_Details_Previews: PreviewProvider {
    static var previews: some View {
        Me_Details(me: Folder.previewFolder)
    }
}
