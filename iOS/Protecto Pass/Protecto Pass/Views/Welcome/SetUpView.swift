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
    
    var body: some View {
        VStack {
            ProgressView()
                .padding(10)
            Text("Loading...")
            Text("This could take a while, depending on your Database count")
                .multilineTextAlignment(.center)
                .font(.caption)
                .padding(.horizontal, 50)
                .padding(.vertical, 0.5)
        }
        
    }
}

internal struct SetUpView_Previews: PreviewProvider {
    static var previews: some View {
        SetUpView()
    }
}
