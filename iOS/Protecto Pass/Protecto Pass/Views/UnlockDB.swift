//
//  UnlockDB.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 18.04.23.
//

import SwiftUI

/// The View to unlock a specific Database
internal struct UnlockDB: View {
    
    /// The Encrypted Database the User wants to unlock
    internal let db : CD_Database
    
    /// The Password to unlock the Database
    @State private var password : String = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            Section {
                Section {
                    Text("Contains \(db.folders!.count) Folders")
                    Text("Contains \(entryCountInDB()) Entries")
                } header: {
                    Text("Content")
                        .font(.headline)
                }
                Divider()
                Section {
                } header: {
                    Text("Encryption")
                        .font(.headline)
                }
                Divider()
            } header: {
                Text("Information")
                    .font(.title)
            }
            TextField("Enter your Password...", text: $password)
                .textCase(.none)
                .textContentType(.password)
                .textInputAutocapitalization(.none)
                .multilineTextAlignment(.leading)
                .textFieldStyle(.roundedBorder)
        }
        .navigationTitle("Unlock \(db.name!)")
        .navigationBarTitleDisplayMode(.automatic)
        .padding(20)
    }
    
    /// Returns the Count of Entries in the complete Database
    private func entryCountInDB() -> Int {
        return 0
    }
    
    private func entryCountInFolder(_ folder : CD_Folder) -> Int {
     return 0
    }
}

/// The Preview for this Database Unlock Screen
internal struct UnlockDB_Previews: PreviewProvider {
    static var previews: some View {
        UnlockDB(db: CD_Database.previewDB)
    }
}
