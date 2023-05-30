//
//  AddDB.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 19.04.23.
//

import SwiftUI

/// Provides a Screen with which the User can add and configure their new Database
internal struct AddDB: View {
    
    /// Dismiss Action to dismiss this View
    @Environment(\.dismiss) private var dismiss
    
    /// The Databases Name
    @State private var name : String = ""
    
    /// The Databases Description
    @State private var description : String = ""
    
    /// The Encryption Algorithm to encrypt the Database
    @State private var encryption : Cryptography.Encryption = .AES256
    
    /// The Type of Storage used to store this Database
    @State private var storage : DB_Header.StorageType = .CoreData
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $name)
                    TextField("Description", text: $description)
                }
                Section {
                    Picker("Encryption", selection: $encryption) {
                        ForEach(Cryptography.Encryption.allCases) {
                            e in
                            Text(e.rawValue)
                        }
                    }
                    Picker("Storage", selection: $storage) {
                        ForEach(DB_Header.StorageType.allCases) {
                            s in
                            Text(s.rawValue)
                        }
                    }
                }
            }
            .navigationTitle("Add Database")
            .navigationBarTitleDisplayMode(.automatic)
            .toolbarRole(.navigationStack)
            .toolbar(.automatic, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        // TODO: add Action Code
                        dismiss()
                    }
                }
            }
        }
    }
}

internal struct AddDB_Previews: PreviewProvider {
    static var previews: some View {
        AddDB()
    }
}
