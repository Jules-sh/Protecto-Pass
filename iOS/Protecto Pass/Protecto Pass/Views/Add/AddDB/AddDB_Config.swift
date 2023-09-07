//
//  AddDB_Config.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 05.09.23.
//

import SwiftUI

internal struct AddDB_Config: View {
    
    @State private var encryption : Cryptography.Encryption = .AES256
    
    @State private var storage : Storage.StorageType = .CoreData
    
    var body: some View {
        VStack {
            Image(systemName: "car")
                .renderingMode(.original)
                .symbolRenderingMode(.hierarchical)
                .resizable()
                .scaledToFit()
                .foregroundColor(.primary)
                .padding(.horizontal, 100)
            Picker("Encryption", selection: $encryption) {
                ForEach(Cryptography.Encryption.allCases) {
                    e in
                    Text(e.rawValue)
                }
            }
            Picker("Storage", selection: $storage) {
                ForEach(Storage.StorageType.allCases) {
                    s in
                    Text(s.rawValue)
                }
            }
        }
    }
}

internal struct AddDB_Config_Previews: PreviewProvider {
    static var previews: some View {
        AddDB_Config()
    }
}
