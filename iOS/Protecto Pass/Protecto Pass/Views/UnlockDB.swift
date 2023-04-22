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
    
    /// The Password entered by the User with which
    /// the App tries to unlock the Database
    @State private var password : String = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            Section {
                Section {
                    Text("Encrypted with \(header.encryption.rawValue)")
                    Text("Stored in \(header.storageType.rawValue)")
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
                Text(db.dbDescription!)
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
    
    // TODO: maybe remove guard statements, if arrays can't be nil. statements only here because i though the fix a bug (wasn't the problem)
    
    /// Returns the count of folders in the complete Database
    private func folderCountInDB() -> Int {
        var count : Int = 0
        guard db.folders != nil else {
            return 0
        }
        count += db.folders!.count
        for folder in db.folders! {
            count += folderCountInFolder(folder as! CD_Folder)
        }
        return count
    }
    
    /// Returns the Count of Folders in the specified Folder
    private func folderCountInFolder(_ folder : CD_Folder) -> Int {
        var count : Int = 0
        count += folder.folders?.count ?? 0
        guard folder.folders != nil else {
            return count
        }
        for innerFolder in folder.folders! {
            count += folderCountInFolder(innerFolder as! CD_Folder)
        }
        return count
    }
    
    /// Returns the Count of Entries in the complete Database
    private func entryCountInDB() -> Int {
        var count : Int = 0
        guard db.folders != nil else {
            return 0
        }
        for folder in db.folders! {
            count += entryCountInFolder(folder as! CD_Folder)
        }
        return count
    }
    
    /// Returns the Number of Entries in the specified Folder
    private func entryCountInFolder(_ folder : CD_Folder) -> Int {
        var count : Int = 0
        count += folder.entries?.count ?? 0
        guard folder.folders != nil else {
            return count
        }
        for innerFolder in folder.folders! {
            count += entryCountInFolder(innerFolder as! CD_Folder)
        }
        return count
    }
    
    /// The Header of this Database as a DB Header Object
    private var header : DB_Header {
        return DB_Header.parseString(string: db.header!)
    }
}

/// The Preview for this Database Unlock Screen
internal struct UnlockDB_Previews: PreviewProvider {
    static var previews: some View {
        UnlockDB(db: CD_Database.previewDB)
    }
}
