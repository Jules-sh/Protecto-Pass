//
//  ContentView.swift
//  Protecto Pass
//
//  Created by Julian Schumacher as ContentView.swift on 01.04.23.
//
//  Renamed by Julian Schumacher to Home.swift on 18.04.23.
//
//  Renamed by Julian Schumacher to Welcome.swift on 18.04.23.
//

import SwiftUI
import CoreData

/// The View that is shown to the User as soon as
/// he opens the App
internal struct Welcome: View {
    
    /// All the Databases of the App.
    internal let databases : [EncryptedDatabase]
    
    var body: some View {
        NavigationStack {
            // Geometry Reader use with Scroll View: https://stackoverflow.com/questions/58226768/how-to-make-the-row-fill-the-screen-width-with-some-padding-using-swiftui
            // Used answer: https://stackoverflow.com/a/58230599
            GeometryReader {
                metrics in
                ScrollView(.horizontal) {
                    LazyHGrid(rows: [GridItem(.flexible())], spacing: 10) {
                        ForEach(databases) {
                            db in
                            container(for: db, width: metrics.size.width - 30)
                        }
                        .padding(15)
                    }
                }
            }
            .toolbar {
                NavigationLink {
                    AddDB()
                } label: {
                    Image(systemName: "plus")
                }
            }
            .navigationTitle("Welcome")
            .navigationBarTitleDisplayMode(.automatic)
        }
    }
    
    /// Returns the Container for the Database
    @ViewBuilder
    private func container(for db : EncryptedDatabase, width : CGFloat) -> some View {
        NavigationLink {
            UnlockDB(db: db)
        } label: {
            VStack {
                Text(db.name)
                    .font(.headline)
                Text(db.dbDescription)
                    .font(.subheadline)
                    .lineLimit(2, reservesSpace: true)
            }
            // - 150 because horiztonal padding is 75
            .frame(width: width - 150)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 75)
        .padding(.vertical, 100)
        .background(Color.gray)
        .cornerRadius(15)
    }
}

/// Preview Provider for the Home View
internal struct Welcome_Previews: PreviewProvider {
    static var previews: some View {
        Welcome(
            databases: [
                EncryptedDatabase.previewDB,
                EncryptedDatabase(
                    name: "test",
                    dbDescription: "description",
                    header: DB_Header(salt: "salt"),
                    folders: []
                )
            ]
        )
    }
}
