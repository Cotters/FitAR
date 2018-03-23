//
//  RaceService.swift
//  FitnessApp
//
//  Created by Josh Cotterell on 04/03/2018.
//  Copyright © 2018 Josh Cotterell. All rights reserved.
//

import UIKit
import FirebaseDatabase

/* Add, Update, Delete races from Firebase Database */
struct RaceService {
    
    let ref = Database.database().reference()
    
    func store(race: Race, forUserWithId userId: String) {
        race.checkpoints.first?.title = "Start"
        race.checkpoints.last?.title = "End"
        let key = "races/\(race.getType().rawValue)"
        
        // Set the checkpoint title as the point of interest if POI race
        if race.getType() == .poi { race.checkpoints.last?.title = race.getName() }
        
        let raceRef = ref.child(key).childByAutoId()
        // Easier to follow using raceId
        race.setId(to: raceRef.key)
        // Store each checkpoint as a child of this raceID
        for index in 0..<race.getNumberOfCheckpoints() {
            guard let checkpoint = race.getCheckpoint(atIndex: index) else { return }
            let checkpointRef = raceRef.child(String(index))
            let checkpointDetails = [
                "title" : checkpoint.title!,
                "latitude" : checkpoint.coordinate.latitude,
                "longitude" : checkpoint.coordinate.longitude
                ] as [String : Any]
            checkpointRef.setValue(checkpointDetails)
        }
        let distance = race.getTotalDistance()
        // Store each race in the user profile with details
        let raceDetails = ["name": race.getName(), "bestTime": 0, "rating": 0, "distance": distance] as [String : Any]
        ref.child("users").child(userId).child(key).child(raceRef.key).setValue(raceDetails)
    }
    
    func saveTime(forRace race: Race, forUserWithId userId: String, time: Double) {
        let key = ref.child("users/\(userId)/races/\(race.getType().rawValue)/\(race.getId())")
        // Update best time - stored in seconds
        key.child("bestTime").setValue(time)
    }
    
    
}
