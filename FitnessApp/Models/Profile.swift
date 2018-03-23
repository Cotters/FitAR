//
//  Profile.swift
//  FitnessApp
//
//  Created by Josh Cotterell on 01/02/2018.
//  Copyright © 2018 Josh Cotterell. All rights reserved.
//

import UIKit
import MapKit
import FirebaseAuth
import FirebaseDatabase

class Profile: NSObject {
    
    var user: User!
    var id: String!
    var name: String?
    var races: [Race]?
    var goals: [UserGoals] = []
    
    var age: Int?
    
    init(user: User) {
        super.init()
        self.user = user
        self.id = user.uid
        self.name = user.displayName
    }
    
    init(name: String, id: String) {
        self.name = name
        self.id = id
    }
    
    func getName() -> String? {
        return self.name
    }
    
    func getId() -> String {
        return self.id
    }
    
}
