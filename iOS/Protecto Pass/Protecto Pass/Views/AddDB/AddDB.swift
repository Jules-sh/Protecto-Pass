//
//  AddDB.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 19.04.23.
//

import SwiftUI

/// Provides a Screen with which the User can add and configure their new Database
internal struct AddDB: View {
    
    /// Dismiss Action to dismiss this View
    @Environment(\.dismiss) private var dismiss
    
    /// The Wrapper to this process
    @StateObject private var creationWrapper : DB_CreationWrapper = DB_CreationWrapper()
    
    /// The Databases Name
    @State private var name : String = ""
    
    /// The Databases Description
    @State private var description : String = ""
    
    /// When set to true, navigate to the next screen
    @State private var next : Bool = false
    
    /// When set to true presents and alert that a name is required
    @State private var errEmptyName : Bool = false
    
    var body: some View {
        NavigationStack {
            Image(systemName: "plus.rectangle.on.rectangle")
                .renderingMode(.original)
                .symbolRenderingMode(.hierarchical)
                .resizable()
                .scaledToFit()
                .padding(.horizontal, 100)
            VStack {
                TextField("Name", text: $name)
                    .padding(.top, 50)
                    .textInputAutocapitalization(.words)
                    .alert("Empty Name", isPresented: $errEmptyName) {
                        
                    } message: {
                        Text("A Name for the Database is required.\nPlease enter one")
                    }
                TextField("Description", text: $description)
            }
            .textInputAutocapitalization(.sentences)
            .textCase(.none)
            .textFieldStyle(.roundedBorder)
            .padding(.horizontal, 25)
            .navigationTitle("Add Database")
            .navigationBarTitleDisplayMode(.automatic)
            .toolbarRole(.navigationStack)
            .toolbar(.automatic, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Next") {
                        done()
                    }
                }
            }
            .navigationDestination(isPresented: $next) {
                AddDB_Password()
                    .environmentObject(creationWrapper)
            }
        }
    }
    
    private func done() -> Void {
        guard !name.isEmpty else {
            errEmptyName.toggle()
            return
        }
        creationWrapper.name = name
        creationWrapper.description = description
        next.toggle()
    }
}

internal struct AddDB_Previews: PreviewProvider {
    static var previews: some View {
        AddDB()
    }
}
