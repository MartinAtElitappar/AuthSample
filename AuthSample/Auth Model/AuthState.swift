//
//  AuthState.swift
//  AlexAuth
//
//  Created by Martin Poulsen on 2022-05-10.
//

import Foundation

enum authState {
    case undefined
    case signedIn
    case signedOut
    case email
    case reAuthenticate
}
