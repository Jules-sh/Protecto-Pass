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
    internal let db : EncryptedDatabase
    
    /// The unlocked Database
    private var unlockedDB : Database
    
    internal init(db : EncryptedDatabase) {
        self.db = db
        unlockedDB = Database.previewDB
    }
    
    /// The Password entered by the User with which
    /// the App tries to unlock the Database
    @State private var password : String = ""
    
    /// When an error occurs while trying to unlock the Database,
    /// toggle this to show the error message
    @State private var errDecryptingPresented : Bool = false
    
    /// If the unlock of the database has been successful, this is set to true
    @State private var unlockSuccess : Bool = false
    
    var body: some View {
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
                Text(db.dbDescription)
            }
            TextField("Enter your Password...", text: $password)
                .textCase(.none)
                .textContentType(.password)
                .textInputAutocapitalization(.none)
                .multilineTextAlignment(.leading)
                .textFieldStyle(.roundedBorder)
        }
        .navigationTitle("Unlock \(db.name)")
        .navigationBarTitleDisplayMode(.automatic)
        .padding(20)
        .navigationDestination(isPresented: $unlockSuccess) {
            Home(db: unlockedDB)
        }
        .alert("Error Unlock Database", isPresented: $errDecryptingPresented) {
        } message: {
            Text("An Error occured while trying to unlock the Database\nMaybe the entered Password is incorrect.\nIf This Error remains, the Database may be corrupt.")
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
    private mutating func tryUnlocking() -> Void {
        do {
            unlockedDB = try db.decrypt()
            unlockSuccess.toggle()
        } catch {
            errDecryptingPresented.toggle()
        }
    }
}

/// The Preview for this Database Unlock Screen
internal struct UnlockDB_Previews: PreviewProvider {
    static var previews: some View {
        UnlockDB(db: EncryptedDatabase.previewDB)
    }
}
