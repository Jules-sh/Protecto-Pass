//
//  AddDB_Overview.swift
//  Protecto Pass
//
//  Created by Julian Schumacher as AddDB_Config.swift on 31.05.23.
//
//  Renamed by Julian Schumacher to AddDB_Overview.swift on 31.05.23.
//

import SwiftUI

/// The Overview Screen of the creation process
/// displaying all your Data and providing further
/// configuration options
internal struct AddDB_Overview: View {
    
    /// The View Context to interact with the CoreData System
    @Environment(\.managedObjectContext) private var viewContext
    
    /// The Creation wrapper for this process
    @EnvironmentObject private var creationWrapper : DB_CreationWrapper
    
    /// The Controller for the Navigation
    @EnvironmentObject private var navigationController : AddDB_Navigation
    
    /// The Encryption Algorithm to encrypt the Database
    @State private var encryption : Cryptography.Encryption = .AES256
    
    /// The Type of Storage used to store this Database
    @State private var storage : DB_Header.StorageType = .CoreData
    
    /// Whether the password is shown or not
    @State private var passwordShown : Bool = false
    
    /// When set to true, displays an alert with an Error Message, because
    /// something went wrong when saving the Database
    @State private var errSavingPresented : Bool = false
    
    var body: some View {
        List {
            Section("General Data") {
                ListTile(name: "Name", data: creationWrapper.name)
                ListTile(name: "Description", data: creationWrapper.description.isEmpty ? "No Description provided" : creationWrapper.description)
            }
            Section {
                ListTile(
                    name: "Password",
                    data: passwordShown ? creationWrapper.password : fakePassword,
                    onTap: {
                        withAnimation {
                            passwordShown.toggle()
                        }
                    },
                    // Not really needed, still entered to tell the System whats going on
                    textContentType: .password
                )
            } header: {
                Text("Password")
            } footer: {
                Text("Tap on the password to display it in clear-text")
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
            } header: {
                Text("Further Configuration")
            } footer: {
                Text("These data can be altered to furthermore configure your database.")
            }
        }
        .alert("Error Saving", isPresented: $errSavingPresented) {
            
        } message: {
            Text("An error occurred while saving the Database, please try again.")
        }
        .navigationTitle("Overview")
        .navigationBarTitleDisplayMode(.automatic)
        .toolbarRole(.navigationStack)
        .toolbar(.automatic, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    done()
                }
            }
        }
    }
    
    /// Creates a fake Password out of placeholders to display
    private var fakePassword : String {
        String(
            (0 ..< creationWrapper.password.count).map {
                _ in
                "•"
            }
        )
    }
    
    /// Function executed when the User pressed the Done Button
    private func done() -> Void {
        creationWrapper.encryption = encryption
        creationWrapper.storageType = storage
        navigationController.db = Database(
            name: creationWrapper.name,
            dbDescription: creationWrapper.description,
            encryption: encryption,
            storageType: storage,
            salt: PasswordGenerator.generateSalt(),
            folders: [],
            entries: [],
            password: creationWrapper.password
        )
        do {
            try Storage.storeDatabase(navigationController.db!.encrypt())
            navigationController.navigationSheetShown.toggle()
            navigationController.openDatabaseToHome.toggle()
        } catch {
            errSavingPresented.toggle()
        }
    }
}

internal struct AddDB_Overview_Previews: PreviewProvider {
    
    /// The Wrapper for this preview
    @StateObject private static var creationWrapperPreview : DB_CreationWrapper = DB_CreationWrapper()
    
    static var previews: some View {
        AddDB_Overview()
            .environmentObject(creationWrapperPreview)
    }
}
