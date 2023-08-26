//
//  EntryDetails.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 28.07.23.
//

import SwiftUI

internal struct EntryDetails: View {
    
    let entry : Entry
    
    var body: some View {
        Text(entry.title)
    }
}

internal struct EntryDetails_Previews: PreviewProvider {
    static var previews: some View {
        EntryDetails(
            entry: Entry(
                title: "Test Entry",
                username: "Username",
                password: "Password1234",
                url: URL(string: "https://julianschumacher.dev"),
                notes: "Account to my personal Website. (Just a test account, not real data)"
            )
        )
    }
}
