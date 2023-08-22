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
    
    @EnvironmentObject private var db : Database
    
    /// The parent folder of this Entry if there is
    @State internal var folder : Folder?
    
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
                .padding(.horizontal, 75)
            Group {
                TextField("Title", text: $title)
                    .textInputAutocapitalization(.words)
                    .padding(.top, 40)
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
            .textFieldStyle(.roundedBorder)
        }
        .padding(.horizontal, 25)
        .navigationTitle("New Entry")
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

internal struct AddEntry_Previews: PreviewProvider {
    
    @StateObject private static var database : Database = Database.previewDB
    
    static var previews: some View {
        AddEntry()
            .environmentObject(database)
        
    }
}
