//
//  ImageListDetails.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 23.01.24.
//

import SwiftUI

internal struct ImageListDetails: View {
    
    @Binding internal var images : [DB_Image]
    
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
        }
    }
}


internal struct ImageListDetails_Previews: PreviewProvider {
    
    @State static var images : [DB_Image] = [DB_Image.previewImage]
    
    static var previews: some View {
        ImageListDetails(images: $images)
    }
}
