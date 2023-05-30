//
//  SetUpView.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 27.05.23.
//

import SwiftUI

/// The View shown to the User while Loading Data
/// in the App and setting up everything
internal struct SetUpView: View {
    
    /// The View Context to interact with Core Data System, loading Data if any are there.
    @Environment(\.managedObjectContext) private var viewContext
    
    /// When the App is ready, this is set to true
    @State private var isReady : Bool = false
    
    /// When set to true, toggles an alert displaying an error message
    @State private var errInitPresented : Bool = false
    
    /// All the encrypted Databases after loading them from the different places
    @State private var databases : [EncryptedDatabase] = []
    
    var body: some View {
        NavigationStack {
            Group {
                ProgressView()
                    .padding(10)
                Text("Loading...")
                Text("This could take a while, depending on your Database size & count")
                    .multilineTextAlignment(.center)
                    .font(.caption)
                    .padding(.horizontal, 50)
                    .padding(.vertical, 0.5)
            }
            .navigationDestination(isPresented: $isReady) {
                Welcome(databases: databases)
            }
        }
        .onAppear {
            load()
        }
        .alert("Error", isPresented: $errInitPresented) {
        } message: {
            Text("An Error occured while loading. Please force close and restart the Application")
        }
        
    }
    
    private func load() -> Void {
        do {
            databases = try Storage.load(with: viewContext)
            isReady.toggle()
        } catch {
            errInitPresented.toggle()
        }
    }
}

internal struct SetUpView_Previews: PreviewProvider {
    static var previews: some View {
        SetUpView()
    }
}
