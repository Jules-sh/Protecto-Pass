//
//  ContentView.swift
//  Protecto Pass
//
//  Created by Julian Schumacher as ContentView.swift on 01.04.23.
//
//  Renamed by Julian Schumacher to Home.swift on 18.04.23.
//

import SwiftUI
import CoreData

/// The View that is shown to the User as soon as
/// he opens the App
internal struct Home: View {
    
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
            List(databases) {
                db in
                NavigationLink(db.name!) {
                    UnlockDB(db: db)
                }
            }
            .navigationTitle("Welcome")
            .navigationBarTitleDisplayMode(.automatic)
        }
    }
}

/// Preview Provider for the Home View
internal struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
