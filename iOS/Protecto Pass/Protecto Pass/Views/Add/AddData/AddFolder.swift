//
//  AddFolder.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 28.07.23.
//

import SwiftUI

/// A Screen to create a new Folder which then
/// is added to the Database
internal struct AddFolder: View {
    
    /// The name of the Folder
    @State private var name : String = ""
    
    /// The Folder this folder is stored in
    @State internal var folder : Folder
    
    var body: some View {
        VStack {
            Image(systemName: "folder")
                .renderingMode(.original)
                .symbolRenderingMode(.hierarchical)
                .resizable()
                .scaledToFit()
                .padding(.horizontal, 75)
            TextField("Name", text: $name)
                .textInputAutocapitalization(.words)
                .textFieldStyle(.roundedBorder)
                .padding(.top, 40)
            TextField("Name", text: $name)
                .textInputAutocapitalization(.sentences)
                .textFieldStyle(.roundedBorder)
        }
        .padding(.horizontal, 25)
        .navigationTitle("New Folder")
        .navigationBarTitleDisplayMode(.automatic)
        .toolbarRole(.editor)
        .toolbar(.automatic, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    
                }
            }
        }
    }
}

internal struct AddFolder_Previews: PreviewProvider {
    static var previews: some View {
        AddFolder(folder: Folder(
            name: "Test",
            description: "Test Description",
            folders: [],
            entries: [])
        )
    }
}
