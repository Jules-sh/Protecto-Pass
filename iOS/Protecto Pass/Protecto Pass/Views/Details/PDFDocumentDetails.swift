//
//  PDFDocumentDetails.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 05.09.24.
//

import SwiftUI
import PDFKit

internal struct PDFDocumentDetails : View {
    
    @Environment(\.dismiss) private var dismiss
    
    @Binding internal var pdfDocument : DB_Document?
    
    @Binding internal var delete : Bool
    
    var body : some View {
        NavigationStack {
            PDFDocumentDetailsView(pdfDocument: pdfDocument)
                .navigationTitle(pdfDocument!.name)
                .navigationBarTitleDisplayMode(.inline)
                .toolbarRole(.automatic)
                .toolbar(.automatic, for: .automatic)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(role: .cancel) {
                            dismiss()
                        } label: {
                            Text("Cancel")
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

// https://stackoverflow.com/questions/65658339/how-to-implement-pdf-viewer-to-swiftui-application
// https://stackoverflow.com/a/65659435
private struct PDFDocumentDetailsView: UIViewRepresentable {
    
    fileprivate let pdfDocument : DB_Document?
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView : PDFView = PDFView()
        pdfView.document = PDFDocument(data: pdfDocument!.document)
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {
        uiView.document = PDFDocument(data: pdfDocument!.document)
    }
}

internal struct PDFDocumentDetailsPreview : PreviewProvider {
    
    @State private static var pdfDocument : DB_Document? = DB_Document(
        document: Data(),
        type: "pdf",
        name: "Test Document",
        created: Date.now,
        lastEdited: Date.now,
        id: UUID()
    )
    
    @State private static var delete : Bool = false
    
    static var previews: some View {
        PDFDocumentDetails(
            pdfDocument: $pdfDocument,
            delete: $delete
        )
    }
}
