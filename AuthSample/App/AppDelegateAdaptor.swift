//
//  AppDelegateAdaptor.swift
//  
//
//  Created by Martin Poulsen on 2022-04-21.
//

import SwiftUI
import Firebase

class AppDelegate: NSObject, UIApplicationDelegate {
    var window: UIWindow?
    
    override init() {
        FirebaseApp.configure()
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = UIColor(Color("AccentColor"))
        return true
    }
}

//Check valid email: https://www.codebales.com/validating-email-in-swift-or-swiftUI
extension String {
    var isValidEmail: Bool {
        let name = "[A-Z0-9a-z]([A-Z0-9a-z._%+-]{0,30}[A-Z0-9a-z])?"
        let domain = "([A-Z0-9a-z]([A-Z0-9a-z-]{0,30}[A-Z0-9a-z])?\\.){1,5}"
        let emailRegEx = name + "@" + domain + "[A-Za-z]{2,8}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPredicate.evaluate(with: self)
    }
}

// Find first name in email address
extension String {
    func emailFirstName() -> String {
        let capEmail = prefix(1).capitalized + dropFirst()
        let fullname = capEmail.components(separatedBy: "@").first
        let firstName = fullname?.components(separatedBy: ".").first ?? ""
        return firstName
    }
    mutating func emailFistName() {
        self = self.emailFirstName()
    }
}


