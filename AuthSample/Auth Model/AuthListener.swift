//
//  AuthListener.swift
//  AlexAuth
//
//  Created by Martin Poulsen on 2022-05-10.
//

import Foundation
import FirebaseAuth
import Combine

struct AuthListener {
    static func listen() -> PassthroughSubject<AuthListenerResult, Error> {
        let subject = PassthroughSubject<AuthListenerResult, Error>()
        Auth.auth().addStateDidChangeListener { (auth, user) in
            let result = AuthListenerResult(auth: auth, user: user)
            subject.send(result)
        }
        return subject
    }
}

struct AuthListenerResult {
    public let auth: Auth
    public let user: User?
}
