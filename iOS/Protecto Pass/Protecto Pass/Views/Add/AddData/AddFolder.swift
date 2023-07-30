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
    
    @State private var name : String = ""
    
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
        }
        .padding(.horizontal, 25)
        .navigationTitle("New Folder")
        .navigationBarTitleDisplayMode(.automatic)
    }
}

internal struct AddFolder_Previews: PreviewProvider {
    static var previews: some View {
        AddFolder()
    }
}
