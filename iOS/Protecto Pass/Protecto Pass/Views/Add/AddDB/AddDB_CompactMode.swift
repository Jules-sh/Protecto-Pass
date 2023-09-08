//
//  AddDB_CompactMode.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 08.09.23.
//

import SwiftUI

internal struct AddDB_CompactMode: View {

    @Environment(\.dismiss) private var dismiss

    @State private var name : String = ""

    @State private var description : String = ""

    @State private var password : String = ""

    @State private var iconName : String = "externaldrive"

    @State private var encryption : Cryptography.Encryption = .AES256

    @State private var storage : Storage.StorageType = .CoreData

    @State private var iconChooserPresented : Bool = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    TextField("Name", text: $name)
                    TextField("Description", text: $description)
                }
                Button {
                    iconChooserPresented.toggle()
                } label: {
                    Label("Icon", systemImage: iconName)
                }
                .sheet(isPresented: $iconChooserPresented) {
                    IconChooser(iconName: $iconName, type: .database)
                }
                Section {
                    Picker("Encryption", selection: $encryption) {
                        ForEach(Cryptography.Encryption.allCases) {
                            e in
                            Text(e.rawValue)
                        }
                    }
                    Picker("Storage", selection: $storage) {
                        ForEach(Storage.StorageType.allCases) {
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
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        done()
                    }
                }
            }
        }
    }

    private func done() -> Void {
    }
}

internal struct AddDB_CompactMode_Previews: PreviewProvider {
    static var previews: some View {
        AddDB_CompactMode()
    }
}
