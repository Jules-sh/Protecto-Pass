//
//  UnlockDBView.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 28.03.23.
//

import SwiftUI

/// View to unlock a Database, given the User enters the
/// correct password and the database can be unlocked.
internal struct UnlockDBView: View {
    
    /// The Database the User wants to unlock at the Moment
    internal let db : CD_Database
    
    /// The Password the User entered.
    /// This will be used to try to unlock the Databse
    @State private var password : String = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            Section {
                Section {
                    Text("Contains \(db.folders!.count) Folders")
                    Text("Contains \(entriesCountInDatabase()) Entries")
                } header: {
                    Text("Content")
                        .font(.headline)
                }
                Divider()
                Section {
                    Text(db.dbDescription!)
                } header: {
                    Text("Database Description")
                        .font(.headline)
                }
            } header: {
                Text("Info")
                    .font(.title)
                Divider()
            }
            .multilineTextAlignment(.leading)
            Divider()
            TextField("Enter your Password...", text: $password)
                .textFieldStyle(.roundedBorder)
                .padding(5)
            NavigationLink("Test") {
                Home()
            }
        }
        .padding(25)
        .navigationTitle("Unlock \(db.name!)")
    }
    
    /// The Count of all Entries in this Database
    private func entriesCountInDatabase() -> Int {
        var count : Int = 0
        for folder in db.folders! {
            count += entriesCountInFolder(folder as! CD_Folder)
        }
        return count
    }
    
    /// The Count of the  entries in the specified folder
    private func entriesCountInFolder(_ folder : CD_Folder) -> Int {
        var count : Int = 0
        for innerFolder in folder.folders! {
            count += entriesCountInFolder(innerFolder as! CD_Folder)
        }
        count += folder.entries!.count
        return count
    }
}

/// Preview for this File
internal struct UnlockDBView_Previews: PreviewProvider {
    static var previews: some View {
        UnlockDBView(db: CD_Database.previewDB)
    }
}
