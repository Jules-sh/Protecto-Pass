//
//  Welcome.swift
//  Protecto Pass
//
//  Created by Julian Schumacher as ContentView.swift on 01.04.23.
//
//  Renamed by Julian Schumacher to Home.swift on 18.04.23.
//
//  Renamed by Julian Schumacher to Welcome.swift on 18.04.23.
//

import CoreData
import SwiftUI

/// The View that is shown to the User as soon as
/// he opens the App
internal struct Welcome: View {

    @Environment(\.compactMode) private var compactMode

    /// The Object to control the navigation of and with the AddDB Sheet
    @EnvironmentObject private var navigationSheet : AddDB_Navigation
    
    /// All the Databases of the App.
    internal let databases : [EncryptedDatabase]

    @State private var selectorPresented : Bool = false
    
    var body: some View {
        NavigationStack {
            build()
                .sheet(isPresented: $navigationSheet.navigationSheetShown) {
                    if compactMode {
                        AddDB_CompactMode()
                            .environmentObject(navigationSheet)
                    } else {
                        AddDB()
                            .environmentObject(navigationSheet)
                    }
                }
                .toolbarRole(.navigationStack)
                .toolbar(.automatic, for: .navigationBar)
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            navigationSheet.navigationSheetShown.toggle()
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
                .navigationTitle("Welcome")
                .navigationBarTitleDisplayMode(.automatic)
                .navigationDestination(isPresented: $navigationSheet.openDatabaseToHome) {
                    Home(db: navigationSheet.db!)
                }
        }
    }
    
    @ViewBuilder
    private func build() -> some View {
        if !databases.isEmpty {
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
        } else {
            VStack {
                Group {
                    Text("No Databases found.")
                    Button("Open from File") {
                        selectorPresented.toggle()
                    }
                    .fileImporter(
                        isPresented: $selectorPresented,
                        allowedContentTypes: [.folder],
                        allowsMultipleSelection: false
                    ) {
                        try! $0.get()
//                        path = try! $0.get().first

                    }
                    Button("Create new one") {
                        navigationSheet.navigationSheetShown.toggle()
                    }
                }.padding(2.5)
            }
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
                Text(db.description)
                    .font(.subheadline)
                    .lineLimit(2, reservesSpace: true)
            }
            // - 150 because horizontal padding is 75
            .frame(width: width - 150)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 75)
        .padding(.vertical, 100)
        .background(Color.gray)
        .cornerRadius(15)
    }
}

internal struct EmptyWelcome_Previews: PreviewProvider {
    static var previews: some View {
        Welcome(
            databases: []
        )
        .environmentObject(AddDB_Navigation())
        .environment(\.compactMode, false)
    }
}

internal struct FilledWelcome_Previews: PreviewProvider {
    static var previews: some View {
        Welcome(
            databases: [
                EncryptedDatabase.previewDB,
            ]
        )
        .environmentObject(AddDB_Navigation())
        .environment(\.compactMode, false)
    }
}

internal struct EmptyWelcomeCompact_Previews: PreviewProvider {
    static var previews: some View {
        Welcome(
            databases: []
        )
        .environmentObject(AddDB_Navigation())
        .environment(\.compactMode, true)
    }
}

internal struct FilledWelcomeCompact_Previews: PreviewProvider {
    static var previews: some View {
        Welcome(
            databases: [
                EncryptedDatabase.previewDB,
            ]
        )
        .environmentObject(AddDB_Navigation())
        .environment(\.compactMode, true)
    }
}
