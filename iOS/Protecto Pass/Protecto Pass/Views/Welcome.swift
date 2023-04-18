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
    
    /// The current selected DB in the Big Frame
    @State private var currentDB : CD_Database? = nil
    
    var body: some View {
        NavigationStack {
            ZStack {
                bigLabel()
            }
            ScrollView(.horizontal) {
                LazyHGrid(rows: [GridItem(.flexible()), GridItem(.flexible())]) {
                    ForEach(databases) {
                        db in
                        Button {
                            currentDB = db
                        } label: {
                            label(for: db)
                        }
                    }
                }
            }
            .navigationTitle("Welcome")
            .navigationBarTitleDisplayMode(.automatic)
        }
    }
    
    @ViewBuilder
    private func bigLabel() -> some View {
        Text(currentDB!.name!)
    }
    
    /// Returns and builds the Label for the specified Database
    @ViewBuilder
    private func label(for db : CD_Database) -> some View {
        Text(db.name!)
    }
}

/// Preview Provider for the Home View
internal struct Welcome_Previews: PreviewProvider {
    static var previews: some View {
        Welcome()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
