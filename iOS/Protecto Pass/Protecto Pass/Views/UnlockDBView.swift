//
//  UnlockDBView.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 28.03.23.
//

import SwiftUI

/// View to unlock a Database, given the User enters the
/// correct password and the database can be unlocked.
internal struct UnlockDBView: View {
    
    /// The Database the User wants to unlock at the Moment
    internal let db : CD_Database
    
    /// The Password the User entered.
    /// This will be used to try to unlock the Databse
    @State private var password : String = ""
    
    var body: some View {
        TextField("Enter your Password...", text: $password)
            .textFieldStyle(.roundedBorder)
    }
}

/// Preview for this File
internal struct UnlockDBView_Previews: PreviewProvider {
    static var previews: some View {
        UnlockDBView(db: CD_Database.previewDB)
    }
}
