//
//  ImageListDetails.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 23.01.24.
//

import SwiftUI

internal struct ImageListDetails: View {
    
    /// The full database needed to store it
    @EnvironmentObject private var db : Database
    
    internal let images : [DB_Image]
    
    var body: some View {
        NavigationStack {
            GeometryReader {
                metrics in
                LazyVGrid(
                    columns: [
                        GridItem(
                            .fixed(metrics.size.width / 3),
                            spacing: 2
                        ),
                        GridItem(
                            .fixed(metrics.size.width / 3),
                            spacing: 2
                        ),
                        GridItem(
                            .fixed(metrics.size.width / 3),
                            spacing: 2
                        ),
                    ],
                    spacing: 2
                ) {
                    ForEach(images) {
                        image in
                        Button {
//                            selectedImage = image
//                            imageDetailsPresented.toggle()
                        } label: {
                            Image(uiImage: image.image)
                                .resizable()
                                .frame(
                                    width: metrics.size.width / 3,
                                    height: metrics.size.width / 3
                                )
                        }
                    }
                }
            }
            .navigationTitle("Images & Videos")
            .navigationBarTitleDisplayMode(.automatic)
            .toolbarRole(.automatic)
            .toolbar(.automatic, for: .automatic)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
}


internal struct ImageListDetails_Previews: PreviewProvider {
    
    @State static private var images : [DB_Image] = [DB_Image.previewImage]
    
    @StateObject static private var db : Database = Database.previewDB
    
    static var previews: some View {
        ImageListDetails(images: [])
            .environmentObject(db)
    }
}
