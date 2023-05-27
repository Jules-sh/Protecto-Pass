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
    
    /// The Context to manage the Core Data Objects
    @Environment(\.managedObjectContext) private var viewContext
    
    /// The actual Fetch Request for the Database Fetch Request
    private static var dbFetchRequest : NSFetchRequest<CD_Database> {
        let request : NSFetchRequest<CD_Database> = CD_Database.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(
                keyPath: \CD_Database.name,
                ascending: true
            )
        ]
        return request
    }
    
    /// The Fetch Request executor for the Databases request
    @FetchRequest(fetchRequest: dbFetchRequest) private var databases : FetchedResults<CD_Database>
    
    var body: some View {
        NavigationStack {
            ScrollView(.horizontal) {
                LazyHGrid(rows: [GridItem(.flexible())], spacing: 25) {
                    ForEach(databases) {
                        db in
                        container(for: db)
                    }
                    .padding(15)
                    NavigationLink {
                        AddDB()
                    } label: {
                        Image(systemName: "plus")
                            .resizable()
                            .scaledToFit()
                            .padding(50)
                            .frame(width: 240, height: 240)
                            .background(Color.gray)
                            .cornerRadius(15)
                            .foregroundColor(.white)
                    }
                }
                .padding(.trailing, 15)
            }
            .navigationTitle("Welcome")
            .navigationBarTitleDisplayMode(.automatic)
        }
    }
    
    /// Returns the Container for the Database
    @ViewBuilder
    private func container(for db : CD_Database) -> some View {
        NavigationLink {
//            UnlockDB(db: db)
        } label: {
            VStack {
                Text(db.name!)
                    .font(.headline)
                Text(db.dbDescription!)
                    .font(.subheadline)
                    .lineLimit(2)
            }
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
        Welcome()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
