//
//  ListTile.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 31.05.23.
//

import SwiftUI

/// A Default List Tile displaying Name and Data
/// of the Data being displayed
internal struct ListTile: View {
    
    /// The Name of this List Tile's Data
    internal let name : String
    
    /// The actual Data of this List Tile
    internal let data : String
    
    /// The Action that is called when the User taps on the
    /// List Tile
    internal var onTap : () -> () = {}
    
#if !os(macOS)
    /// The Text Content Type of the Data Part
    internal var textContentType : UITextContentType? = nil
#endif
    
    var body: some View {
        HStack {
            Text(name)
            Spacer()
            Text(data)
                .foregroundColor(.gray)
#if !os(macOS)
                .textContentType(textContentType)
#endif
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
}

struct ListTile_Previews: PreviewProvider {
    static var previews: some View {
        ListTile(
            name: "Test",
            data: "Value",
            onTap: {
                print("On Tap pressed")
            }
        )
    }
}
