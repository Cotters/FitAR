//
//  RaceService.swift
//  FitnessApp
//
//  Created by Josh Cotterell on 04/03/2018.
//  Copyright © 2018 Josh Cotterell. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import MapKit

/* Add, Update, Delete, Retrieve races from Firebase Database */
/// Handles all the server side functionality such as retrieving a list of races
struct RaceService {
    
    let ref = Database.database().reference()
    
    var delegate: FetchRacesDelegate?
    
    // MARK: - Race retriever methods
    /// Fetches races of a specified type for a specified user.
    func fetchRaces(ofType raceType: RaceType, for user: User) {
        var races: [Race] = []
        
        let key = raceType
        let ref = Database.database().reference()
        
        ref.child("users/\(user.uid)/races/\(key)").observe(.value) { (snapshot) in
            if !snapshot.exists() {
                // User has no races - return out
                return
            }
            let dbRaces = snapshot.value as! NSDictionary
            
            // Fetch each races details used in the tableView
            for race in dbRaces {
                guard let raceId = race.key as? String,
                    let raceDetails = race.value as? NSDictionary else { return }
                
                // Fetching only the details and not the checkpoints is a lot faster.
                guard let raceName = raceDetails["name"] as? String,
                    let rating = raceDetails["rating"] as? Double,
                    let distance = raceDetails["distance"] as? Double,
                    let bestTime = raceDetails["bestTime"] as? Double else { return }
                
                // Create an initial race
                let race = Race(type: raceType, name: raceName, id: raceId, rating: rating, distance: distance, bestTime: bestTime)
                races.append(race)
            }
            self.delegate?.loadRaces(races, ofType: raceType)
        }
    }
    
    /// Fetches challenges made for the user.
    func fetchChalenges(for profile: Profile) {
        var races: [Race] = []
        
        let ref = Database.database().reference()
        let userId = profile.id
        
        ref.child("users/\(String(describing: userId))/races/challenge").observe(.value) { (snapshot) in
            if !snapshot.exists() {
                // User has no challenges - return out
                return
            }
            let challenges = snapshot.value as! NSDictionary
            
            // For each stored race convert it into a checkpoint race and store in this Profile
            for race in challenges {
                // Fetch only the details
                guard let raceId = race.key as? String,
                    let raceDetails = race.value as? NSDictionary else { return }
                // TODO: Distance - stored in DB
                guard let raceName = raceDetails["name"] as? String,
                    let rating = raceDetails["rating"] as? Double,
                    let bestTime = raceDetails["bestTime"] as? Double,
                    let distance = raceDetails["distance"] as? Double else { return }
                
                // Make into challenge race
                let race = Race(type: .challenge, name: raceName, id: raceId, rating: rating, distance: distance, bestTime: bestTime)
                races.append(race)
            }
            self.delegate?.loadRaces(races, ofType: .challenge)
        }
    }
    
    /// Fetches all checkpoints contained in a race.
    func fetchCheckpoints(for race: Race) {
        if race.checkpoints.count > 0 {
            // Already been fetched. Avoid duplicate
            self.delegate?.loadCheckpoints(for: race)
            return
        }
        
        let key = race.type
        let ref = Database.database().reference()
        
        ref.child("races/\(key)/\(race.id)").observeSingleEvent(of: .value, with: { (snapshot) in
            // A race is an array of checkpoints, but we need to convert into MKPointAnnotation first.
            for checkpoint in snapshot.children {
                let snap = checkpoint as! DataSnapshot
                let dict = snap.value as! NSDictionary
                
                let title = dict["title"] as! String
                let latitude = dict["latitude"] as! Double
                let longitude = dict["longitude"] as! Double
                
                let point = MKPointAnnotation()
                point.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                point.title = title
                point.subtitle = "Distance: \(race.getDistanceFromLastPoint(to: point))"
                race.addCheckpoint(point)
            }
            self.delegate?.loadCheckpoints(for: race)
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    
    // MARK: - Save, Update, Delete
    /// Store a new race in Database
    func store(race: Race,  userId: String) {
        race.checkpoints.first?.title = "Start"
        race.checkpoints.last?.title = "End"
        let key = "races/\(race.type)"
        
        // Set the checkpoint title as the point of interest if POI race
        if race.type == .poi { race.checkpoints.last?.title = race.name }
        
        // Create an id to uniquely identify each race
        let raceRef = ref.child(key).childByAutoId()
        race.id = raceRef.key
        // Store each checkpoint as a child of this raceId
        var raceCheckpoints: [String:[String:Any]] = [:]
        for index in 0..<race.checkpoints.count {
            guard let checkpoint = race.getCheckpoint(atIndex: index) else { return }
            let checkpointDetails = [
                "title" : checkpoint.title!,
                "latitude" : checkpoint.coordinate.latitude,
                "longitude" : checkpoint.coordinate.longitude
                ] as [String : Any]
            // Collect a dictionary of details
            raceCheckpoints[String(index)] = checkpointDetails
        }
        // Perform a single write to database for checkpoints
        raceRef.setValue(raceCheckpoints)
        let distance = race.calculateTotalDistance()
        // Store each race in the user tree with details - bestTime is a year in seconds
        let raceDetails = ["name": race.name, "bestTime": 31536000, "rating": 0, "distance": distance] as [String : Any]
        ref.child("users").child(userId).child(key).child(raceRef.key).setValue(raceDetails)
    }
    
    /// Save a new best time for a completed race.
    func save(time: Double, for race: Race, using userId: String) {
        let key = ref.child("users/\(userId)/races/\(race.type)/\(race.id)")
        // Update best time - stored in seconds
        key.child("bestTime").setValue(time)
    }
    
    /// Update the stored data about a race. E.g. the name of the race.
    func update(_ race: Race, forUser user: User) {
        let key = "races/\(race.type)/\(race.id)"
        
        // Update checkpoints (races tree)
        var updates: [String:[String:Any]] = [:]
        for index in 0..<race.checkpoints.count {
            guard let checkpoint = race.getCheckpoint(atIndex: index) else { return }
            let checkpointDetails = [
                "title" : checkpoint.title!,
                "latitude" : checkpoint.coordinate.latitude,
                "longitude" : checkpoint.coordinate.longitude
            ] as [String : Any]
            // Add value to updates
            updates[String(index)] = checkpointDetails
        }
        // Perform a single update to only changed values
        ref.child(key).updateChildValues(updates)
        
        // Update distance
        let newDistance = race.calculateTotalDistance()
        ref.child("users/\(user.uid)/\(key)/distance").setValue(newDistance)
    }
    
    /// Permanently delete a race from the database.
    func delete(race: Race, for user: User) {
        let ref = Database.database().reference()
        let racePath = "races/\(race.type)/\(race.id)"
        
        // Remove from all races
        ref.child(racePath).removeValue()
        // Remove from user races
        ref.child("users/\(user.uid)").child(racePath).removeValue()
    }
}
