//
//  Home.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 27.05.23.
//

import SwiftUI

/// The Home View, containing the unlocked
/// Database
internal struct Home: View {
    
    /// The Database that the User has just unlocked
    @StateObject internal var db : Database
    
    var body: some View {
        NavigationStack {
            List {
                Section("Entries") {
                    
                }
                Section("Folder") {
                    
                }
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.automatic)
            .toolbarRole(.navigationStack)
            .toolbar(.automatic, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
}

/// The Preview for the Home View
internal struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home(db: Database.previewDB)
    }
}
