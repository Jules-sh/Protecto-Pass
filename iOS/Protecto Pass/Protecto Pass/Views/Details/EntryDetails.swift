//
//  EntryDetails.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 28.07.23.
//

import SwiftUI

internal struct EntryDetails: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @Binding internal var entry : Entry?
    
    @State private var passwordShown : Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                Section("Data") {
                    ListTile(name: "Username", data: entry!.username, textContentType: .username)
                    // TODO: change "..."
                    ListTile(name: "Password", data: passwordShown ? entry!.password : PasswordGenerator.generateFakePassword(count: entry!.password.count), textContentType: .password) {
                        withAnimation {
                            passwordShown.toggle()
                        }
                    }
                    if let link = entry!.url {
                        ListTile(name: "Link", data: link.relativeString) {
                            UIApplication.shared.open(link)
                        }
                    }
                }
                Section("Timeline") {
                    ListTile(name: "Last edited", date: entry!.lastEdited)
                    ListTile(name: "Created", date: entry!.created)
                }
            }
            .navigationTitle(entry!.title)
            .navigationBarTitleDisplayMode(.automatic)
            .toolbarRole(.automatic)
            .toolbar(.automatic, for: .automatic)
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

internal struct EntryDetails_Previews: PreviewProvider {
    
    @State private static var entry : Entry? = Entry.previewEntry
    
    static var previews: some View {
        EntryDetails(entry: $entry)
    }
}
