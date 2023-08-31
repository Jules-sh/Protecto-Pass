//
//  EditEntry.swift
//  Protecto Pass
//
//  Created by Julian Schumacher as AddEntry.swift on 28.07.23.
//
//  Renamed by Julian Schumacher to EditEntry.swift on 26.08.23.
//

import SwiftUI

/// View to add a new Entry with all it's data.
/// This entry is stored in the current folder
internal struct EditEntry: View {
    
    @Environment(\.managedObjectContext) private var context
    
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject private var db : Database
    
    /// The parent folder of this Entry if there is
    @State internal var folder : Folder?
    
    @State private var title : String = ""
    
    @State private var username : String = ""
    
    @State private var password : String = ""
    
    @State private var url : String = ""
    
    @State private var notes : String = ""
    
    @State private var errStoring : Bool = false
    
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
        .alert("Error saving", isPresented: $errStoring) {
            Button("Cancel", role: .cancel) {}
            Button("Try again") { save() }
        } message: {
            Text("An Error occurred when trying to save the data.\nPlease try again")
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
    
    /// Saves the data and dismisses this View
    private func save() -> Void {
        do {
            try Storage.storeDatabase(db, context: context)
            dismiss()
        } catch {
            errStoring.toggle()
        }
    }
}

internal struct EditEntry_Previews: PreviewProvider {
    
    @StateObject private static var database : Database = Database.previewDB
    
    static var previews: some View {
        EditEntry()
            .environmentObject(database)
        
    }
}
