//
//  UnlockHelper.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 28.03.23.
//

import Foundation

/// The Helper to manage the unlock Process of the Database
/// the User choses to unlock
internal class UnlockHelper : ObservableObject {
    
    internal enum UnlockState {
        case locked
        case unlocked
    }
    
    /// The Database that has been unlocked
    @Published internal var unlockedDatabase : Database
    
    @Published internal var unlockState : UnlockState = .locked
    
    internal init() {
        // TODO: work on the standard Database
        unlockedDatabase = Database.previewDB
    }
}
