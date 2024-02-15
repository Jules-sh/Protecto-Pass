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
    
    let images : [Int] = []
    
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
//                    ForEach(images) {
//                        image in
//                        Button {
////                            selectedImage = image
////                            imageDetailsPresented.toggle()
//                        } label: {
//                            Image(uiImage: image.image)
//                                .resizable()
//                                .frame(
//                                    width: metrics.size.width / 3,
//                                    height: metrics.size.width / 3
//                                )
//                        }
//                    }
                }
            }
        }
    }
}


internal struct ImageListDetails_Previews: PreviewProvider {
    
    @State static private var images : [DB_Image] = [DB_Image.previewImage]
    
    @StateObject static private var db : Database = Database.previewDB
    
    static var previews: some View {
        ImageListDetails()
            .environmentObject(db)
    }
}
