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
    
    /// The Database to store this Object in
    @EnvironmentObject private var db : Database
    
    /// The parent folder of this Entry if there is
    @State internal var folder : Folder?
    
    /// The Title of this entry
    @State private var title : String = ""
    
    /// The Username of this Entry.
    /// This typically is a Name, not a link
    @State private var username : String = ""
    
    /// The Password stored in this Entry.
    /// This is the most important part
    @State private var password : String = ""
    
    /// The URL to where the entry is connected to
    @State private var url : String = ""
    
    /// Some Notes to this Entry
    @State private var notes : String = ""
    
    /// Whether or not an error has appeared storing the Database
    @State private var errStoring : Bool = false
    
    /// The name of the icon representing this Entry
    @State private var iconName : String = "doc"
    
    /// Whether or not the icon Chooser is shown
    @State private var iconChooserShown : Bool = false
    
    internal init(entry : Entry, folder : Folder? = nil) {
        self.title = entry.title
        self.username = entry.username
        self.password = entry.password
        self.url = entry.url?.absoluteString ?? ""
        self.notes = entry.notes
        self.iconName = entry.iconName
        self.folder = folder
    }
    
    internal init(folder : Folder? = nil) {
        self.folder = folder
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Button {
                    iconChooserShown.toggle()
                } label: {
                    Image(systemName: iconName)
                        .renderingMode(.original)
                        .symbolRenderingMode(.hierarchical)
                        .resizable()
                        .scaledToFit()
                        .padding(.horizontal, 75)
                        .foregroundStyle(.foreground)
                }
                .sheet(isPresented: $iconChooserShown) {
                    IconChooser(iconName: $iconName, type: .entry)
                }
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
                            .textContentType(.URL)
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
                    Button("Done") { save() }
                }
            }
        }
    }
    
    /// Saves the data and dismisses this View
    private func save() -> Void {
        do {
            try Storage.storeDatabase(
                db,
                context: context,
                newElements: [
                    Entry(
                        title: title,
                        username: username,
                        password: password,
                        url: URL(string: url),
                        notes: notes,
                        iconName: iconName,
                        // TODO: add loadable resources
                        documents: [],
                        created: Date.now,
                        lastEdited: Date.now,
                        id: UUID()
                    )
                ]
            )
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
