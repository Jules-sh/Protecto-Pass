//
//  FolderDetails.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 28.07.23.
//

import SwiftUI

internal struct FolderDetails: View {
    
    let folder : Folder
    
    var body: some View {
        Text(folder.name)
    }
}

internal struct FolderDetails_Previews: PreviewProvider {
    static var previews: some View {
        FolderDetails(
            folder: Folder(
                name: "Test Folder",
                description: "Test Description",
                folders: [],
                entries: []
            )
        )
    }
}
