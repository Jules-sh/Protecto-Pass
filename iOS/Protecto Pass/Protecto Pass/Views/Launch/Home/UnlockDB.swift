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
    @Binding internal var db : EncryptedDatabase
    
    @EnvironmentObject private var navigationSheet : AddDB_Navigation
    
    /// The unlocked Database
    @State private var unlockedDB : Database? = nil
    
    /// The Password entered by the User with which
    /// the App tries to unlock the Database
    @State private var password : String = ""
    
    /// When an error occurs while trying to unlock the Database,
    /// toggle this to show the error message
    @State private var errDecryptingPresented : Bool = false
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                Section {
                    Section {
                        Text("Encrypted with \(db.header.encryption.rawValue)")
                        Text("Stored in \(db.header.storageType.rawValue)")
                    } header: {
                        Text("General")
                            .font(.headline)
                    }
                    Divider()
                    Section {
                        Text("Contains \(folderCountInDB()) Folders")
                        Text("Contains \(entryCountInDB()) Entries")
                    } header: {
                        Text("Content")
                            .font(.headline)
                    }
                    Divider()
                } header: {
                    Text("Information")
                        .font(.title)
                    Divider()
                } footer: {
                    Text(db.description)
                }
                PasswordField(title: "Enter your Password...", text: $password)
                    .multilineTextAlignment(.leading)
                    .textFieldStyle(.roundedBorder)
            }
            .navigationTitle("Unlock \(db.name)")
            .navigationBarTitleDisplayMode(.automatic)
            .padding(20)
            .alert("Error Unlock Database", isPresented: $errDecryptingPresented) {
            } message: {
                Text("An Error occurred while trying to unlock the Database\nMaybe the entered Password is incorrect.\nIf This Error remains, the Database may be corrupt.")
            }
            .toolbarRole(.navigationStack)
            .toolbar(.automatic, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Unlock") {
                        tryUnlocking()
                    }
                }
            }
        }
    }
    
    
    /// Returns the count of folders in the complete Database
    private func folderCountInDB() -> Int {
        var count : Int = 0
        count += db.folders.count
        for folder in db.folders {
            count += folderCountInFolder(folder)
        }
        return count
    }
    
    /// Returns the Count of Folders in the specified Folder
    private func folderCountInFolder(_ folder : EncryptedFolder) -> Int {
        var count : Int = 0
        count += folder.folders.count
        for innerFolder in folder.folders {
            count += folderCountInFolder(innerFolder)
        }
        return count
    }
    
    /// Returns the Count of Entries in the complete Database
    private func entryCountInDB() -> Int {
        var count : Int = 0
        for folder in db.folders {
            count += entryCountInFolder(folder)
        }
        return count
    }
    
    /// Returns the Number of Entries in the specified Folder
    private func entryCountInFolder(_ folder : EncryptedFolder) -> Int {
        var count : Int = 0
        count += folder.entries.count
        for innerFolder in folder.folders {
            count += entryCountInFolder(innerFolder)
        }
        return count
    }
    
    /// Try to unlock the Database with the provided password
    private func tryUnlocking() -> Void {
        do {
            let localDatabase : Database = try db.decrypt(using: password)
            unlockedDB = localDatabase
            navigationSheet.db = unlockedDB
            navigationSheet.openDatabaseToHome.toggle()
        } catch {
            errDecryptingPresented.toggle()
        }
    }
}

/// The Preview for this Database Unlock Screen
internal struct UnlockDB_Previews: PreviewProvider {
    
    @State private static var db : EncryptedDatabase = EncryptedDatabase.previewDB
    static var previews: some View {
        UnlockDB(db: $db)
    }
}
