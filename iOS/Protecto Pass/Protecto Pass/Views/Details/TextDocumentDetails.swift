//
//  TextDocumentDetails.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 06.09.24.
//

import SwiftUI

internal struct TextDocumentDetails: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @Binding internal var document : DB_Document?
    
    @Binding internal var delete : Bool
    
    var body: some View {
        NavigationStack {
            ScrollView {
                Text(DataConverter.dataToString(document!.document))
            }
            .padding(.horizontal, 25)
            .navigationTitle(document!.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarRole(.automatic)
            .toolbar(.automatic, for: .automatic)
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
                            Label("Information", systemImage: "info.circle")
                        }
                        Divider()
                        Button(role: .destructive) {
                            delete = true
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


internal struct TextDocumentDetailsPreview : PreviewProvider {
    
    @State private static var document : DB_Document? = DB_Document(
        document: DataConverter.stringToData("Test Data"),
        type: "txt",
        name: "Test Document",
        created: Date.now,
        lastEdited: Date.now,
        id: UUID()
    )
    
    @State private static var delete : Bool = false
    
    static var previews: some View {
        TextDocumentDetails(document: $document, delete: $delete)
    }
}
