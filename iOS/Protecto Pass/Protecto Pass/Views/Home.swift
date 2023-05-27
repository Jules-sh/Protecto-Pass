//
//  Home.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 27.05.23.
//

import SwiftUI

internal struct Home: View {
    
    internal let db : Database
    
    var body: some View {
        NavigationStack {
            
        }
    }
}

internal struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home(db: Database.previewDB)
    }
}
