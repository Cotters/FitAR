//
//  UserContainedViewController.swift
//  FitnessApp
//
//  Created by Josh Cotterell on 27/02/2018.
//  Copyright © 2018 Josh Cotterell. All rights reserved.
//

import UIKit
import FirebaseAuth

class UserContainedViewController: UIViewController {
    
    var user: User!
    var profile: Profile!
    var handle: AuthStateDidChangeListenerHandle!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if user == nil {
                // Show login/register pages if user isn't signed in
                self.navigationController?.presentLoginScreen()
            } else {
                // Safely unwrap user object and store in MainView
                guard let user = user else { return }
                self.user = user
                self.profile = Profile(user: user)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    override func viewDidLoad() {
        if let currentUser = Auth.auth().currentUser {
            self.user = currentUser
            self.profile = Profile(user: user)
        } else {
            self.navigationController?.presentLoginScreen()
        }
        
    }
}
