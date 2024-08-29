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
    @Binding internal var image : DB_Image?
    
    @Binding internal var deleted : Bool
    
    var body: some View {
        NavigationStack {
            Image(uiImage: image!.image)
                .resizable()
                .scaledToFit()
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
                            NavigationLink {
                                ImageInfo(image: image!)
                            } label: {
                                Label("Info", systemImage: "info.circle")
                            }
                            Divider()
                            Button(role: .destructive) {
                                deleted = true
                                dismiss()
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
    
    @State static private var image : DB_Image? = DB_Image.previewImage
    
    @State static private var deleted : Bool = false
    
    static var previews: some View {
        ImageDetails(image: $image, deleted: $deleted)
    }
}
