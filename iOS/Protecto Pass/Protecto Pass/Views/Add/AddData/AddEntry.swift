//
//  AddEntry.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 28.07.23.
//

import SwiftUI

/// View to add a new Entry with all it's data.
/// This entry is stored in the current folder
internal struct AddEntry: View {
    
    /// The folder the user currently is active in
    // TODO: make state variable with a switch for the user to decide which folder this entry contains
//    internal let folder : Folder
    
    @State private var title : String = ""
    
    @State private var username : String = ""
    
    @State private var password : String = ""
    
    @State private var url : String = ""
    
    @State private var notes : String = ""
    
    var body: some View {
        VStack {
            Image(systemName: "doc")
                .renderingMode(.original)
                .symbolRenderingMode(.hierarchical)
                .resizable()
                .scaledToFit()
                .padding(.horizontal, 100)
            List {
                TextField("Title", text: $title)
                    .textInputAutocapitalization(.words)
                Group {
                    TextField("Username", text: $username)
                        .textContentType(.username)
                    TextField("Password", text: $password)
                        .textContentType(.password)
                    TextField("URL", text: $url)
                        .textContentType(.password)
                }
                .textInputAutocapitalization(.never)
                TextField("Notes", text: $notes, axis: .vertical)
                    .lineLimit(5...10)
                    .textInputAutocapitalization(.sentences)
            }
        }
        .navigationTitle("New Entry")
        .navigationBarTitleDisplayMode(.automatic)
    }
}

internal struct AddEntry_Previews: PreviewProvider {
    static var previews: some View {
        AddEntry()
    }
}
