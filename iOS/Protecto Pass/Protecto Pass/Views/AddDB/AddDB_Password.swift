//
//  AddDB_Password.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 30.05.23.
//

import SwiftUI

/// View in the Database creation process to enter a password
internal struct AddDB_Password: View {
    
    /// The current name of the lock symbols image
    @State private var lockName : String = "lock.open"
    
    /// The Password chosen to create the Database
    @State private var password : String = ""
    
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
    
    /// When toggled, an alert is displayed telling the user somthing
    /// went wrong
    @State private var errChecking : Bool = false
    
    var body: some View {
        VStack {
            Image(systemName: lockName)
                .resizable()
                .scaledToFit()
                .padding(.horizontal, 100)
            TextField("Password", text: $password)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal, 25)
                .padding(.top, 50)
                .onChange(of: password) {
                    _ in
                    checkRequirements()
                }
            HStack {
                VStack(alignment: .leading) {
                    Text("Password requirements:")
                    requirementRow("8 Characters", isMet: isLengthMet)
                    requirementRow("At least 1 Upper Case Letter", isMet: containsUpperCaseLetter)
                    requirementRow("At least 1 Lower Case Letter", isMet: containsLowerCaseLetter)
                    requirementRow("At least 1 number", isMet: containsNumber)
                    requirementRow("At least 1 symbol", isMet: containsSymbol)
                }
                .alert("Error", isPresented: $errChecking) {
                    Button("Ok") {}
                } message: {
                    Text("An Error appear, please try again")
                }
                .multilineTextAlignment(.leading)
                .padding(.horizontal, 25)
                Spacer()
            }
        }
        .navigationTitle("Password")
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
        // TODO: + hinter regex needed?
        // Length
        if password.count >= 8 {
            isLengthMet = true
        } else {
            isLengthMet = false
        }
        do {
            // Upper Case
            if password.contains(try Regex("[A-Z]+")) {
                containsUpperCaseLetter = true
            } else {
                containsUpperCaseLetter = false
            }
            // Lower Case
            if password.contains(try Regex("[a-z]+")) {
                containsLowerCaseLetter = true
            } else {
                containsLowerCaseLetter = false
            }
            // Number
            if password.contains(try Regex("[0-9]+")) {
                containsNumber = true
            } else {
                containsNumber = false
            }
            // Symbols
            if password.contains("?") {
                containsSymbol = true
            } else {
                containsSymbol = false
            }
        } catch {
            errChecking.toggle()
        }
    }
}

internal struct AddDB_Password_Previews: PreviewProvider {
    static var previews: some View {
        AddDB_Password()
    }
}
