//
//  ImageDetails.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 05.09.23.
//

import SwiftUI

/// Struct to display an Image stored in this Database
internal struct ImageDetails: View {
    
    /// Action to dismiss this View
    @Environment(\.dismiss) private var dismiss
    
    /// The Image displayed in this View
    internal let image : DB_Image
    
    var body: some View {
        NavigationStack {
            Image(uiImage: image.image)
                .toolbarRole(.navigationStack)
                .toolbar(.automatic, for: .navigationBar)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel", role: .cancel) {
                            dismiss()
                        }
                    }
                    ToolbarItem(placement: .primaryAction) {
                        Menu {
                            Button {
                                
                            } label: {
                                Label("Info", systemImage: "info.circle")
                            }
                            Divider()
                            Button(role: .destructive) {
                                
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }
        }
    }
}

internal struct ImageDetails_Previews: PreviewProvider {
    static var previews: some View {
        ImageDetails(image: DB_Image.previewImage)
    }
}
