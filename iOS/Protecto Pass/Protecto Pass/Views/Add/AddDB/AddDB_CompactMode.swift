//
//  AddDB_CompactMode.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 08.09.23.
//

import SwiftUI

internal struct AddDB_CompactMode: View {

    @Environment(\.dismiss) private var dismiss

    /// The Name of the Database
    @State private var name : String = ""

    /// Description for the Database
    @State private var description : String = ""

    /// The Password for this Database
    @State private var password : String = ""

    /// The Icon Name for this Database
    @State private var iconName : String = "externaldrive"

    /// The Encryption the User chose to use when encrypting this Database
    @State private var encryption : Cryptography.Encryption = .AES256

    /// How to store the Database
    @State private var storage : Storage.StorageType = .CoreData

    /// Whether or not to allow biometrics to unlock this Database
    @State private var allowBiometrics : Bool = false

    /// Whether or not the icon chooser is presented
    @State private var iconChooserPresented : Bool = false

    /// Set to true if the password contains 8 or more character
    @State private var isLengthMet : Bool = false

    /// Set to true if the password contains at least one upper case letter
    @State private var containsUpperCaseLetter : Bool = false

    /// Set to true if the password contains at least one lower case letter
    @State private var containsLowerCaseLetter : Bool = false

    /// Set to true if the password contains at least one number
    @State private var containsNumber : Bool = false

    /// Set to true if the password contains at least one symbol
    @State private var containsSymbol : Bool = false

    /// When toggled, an alert is displayed telling the user something
    /// went wrong
    @State private var errChecking : Bool = false

    /// When set to true, presents an alert, stating that not all requirements are met.
    @State private var errRequirements : Bool = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    TextField("Name", text: $name)
                    TextField("Description", text: $description)
                } header: {
                    Text("General")
                }
                Button {
                    iconChooserPresented.toggle()
                } label: {
                    Label("Icon", systemImage: iconName)
                }
                .sheet(isPresented: $iconChooserPresented) {
                    IconChooser(iconName: $iconName, type: .database)
                }
                Section("Security") {
                    Toggle("Allow Biometrics", isOn: $allowBiometrics)
                    Picker("Encryption", selection: $encryption) {
                        ForEach(Cryptography.Encryption.allCases) {
                            e in
                            Text(e.rawValue)
                        }
                    }
                }
                Section {
                    PasswordField(title: "Password", text: $password, newPassword: true)
                        .onChange(of: password) {
                            _ in
                            checkRequirements()
                        }
                        .alert("Error", isPresented: $errChecking) {
                            Button("Ok") {}
                        } message: {
                            Text("An Error appear, please try again")
                        }
                        .alert("Missing requirements", isPresented: $errRequirements) {
                            Button("Ok") {}
                        } message: {
                            Text("Not all requirements are met.\nPlease meet all the requirements and then try again")
                        }
                } header: {
                    EmptyView()
                } footer: {
                    VStack(alignment: .leading) {
                        Text("Password requirements:")
                        Text("At least:")
                        requirementRow("8 Characters", isMet: isLengthMet)
                        requirementRow("1 Upper Case Letter", isMet: containsUpperCaseLetter)
                        requirementRow("1 Lower Case Letter", isMet: containsLowerCaseLetter)
                        requirementRow("1 number", isMet: containsNumber)
                        requirementRow("1 symbol", isMet: containsSymbol)
                    }
                }
                Section {
                    Picker("Storage", selection: $storage) {
                        ForEach(Storage.StorageType.allCases) {
                            s in
                            Text(s.rawValue)
                        }
                    }
                }
            }
            .navigationTitle("Add Database")
            .navigationBarTitleDisplayMode(.automatic)
            .toolbarRole(.navigationStack)
            .toolbar(.automatic, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        done()
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func requirementRow(_ requirement : String, isMet : Bool) -> some View {
        HStack {
            Image(systemName: isMet ? "checkmark.circle" : "x.circle")
            // Needed for correct color rendering
                .renderingMode(.template)
            // Makes the symbols appear less bold
                .symbolRenderingMode(.hierarchical)
                .foregroundColor(isMet ? .green : .red)
            Text(requirement)
        }
    }

    /// Checks for the requirements and sets the boolean values
    /// depending on their state
    private func checkRequirements() -> Void {
        // TODO: maybe change regex
        // Length
        isLengthMet = password.count >= 8
        do {
            // Upper Case
            containsUpperCaseLetter = password.contains(try Regex("[A-Z]"))
            // Lower Case
            containsLowerCaseLetter = password.contains(try Regex("[a-z]"))
            // Number
            containsNumber = password.contains(try Regex("[0-9]"))
            // Symbols
            containsSymbol = password.contains(try Regex("[^A-Za-z0-9\\w\\s]"))
        } catch {
            errChecking.toggle()
        }
    }

    /// Whether all requirements are met or not
    private var allChecked : Bool {
        containsUpperCaseLetter && containsLowerCaseLetter && containsNumber && containsSymbol && password.count >= 8
    }

    /// Executed when the user pressed "done"
    private func done() -> Void {
        guard allChecked else {
            errRequirements.toggle()
            return
        }
    }
}

internal struct AddDB_CompactMode_Previews: PreviewProvider {
    static var previews: some View {
        AddDB_CompactMode()
    }
}
