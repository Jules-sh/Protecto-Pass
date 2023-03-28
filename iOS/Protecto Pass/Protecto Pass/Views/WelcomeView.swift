//
//  WelcomeView.swift
//  Protecto Pass
//
//  Created by Julian Schumacher as ContentView.swift on 28.03.23.
//
//  Renamed by Julian Schumacher to WelcomeView.swift on 28.03.2023
//

import SwiftUI
import CoreData

internal struct WelcomeView: View {
    /// The View Context to interact with the Core Data Manager and
    /// its Objects
    @Environment(\.managedObjectContext) private var viewContext
    
    /// The Fetch Request to fetch all the Databases from the Core Data
    /// Manager
    @FetchRequest(fetchRequest: dbFetchRequest) private var databases : FetchedResults<CD_Database>
    
    /// The Fetch Request Object being used to configure
    /// the Fetch Request which gets all the databases
    private static var dbFetchRequest : NSFetchRequest<CD_Database> {
        let request : NSFetchRequest = CD_Database.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \CD_Database.name, ascending: true)
        ]
        return request
    }
    
    var body: some View {
        NavigationView {
            VStack {
                List(databases) {
                    database in
                    NavigationLink(database.name!) {
                        
                    }
                }
            }
            .navigationTitle("Welcome")
            .navigationBarTitleDisplayMode(.automatic)
        }
    }
}

/// The Preview for this File
internal struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
