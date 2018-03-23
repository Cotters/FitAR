//
//  RaceRetriever.swift
//  FitnessApp
//
//  Created by Josh Cotterell on 03/03/2018.
//  Copyright © 2018 Josh Cotterell. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import MapKit

struct RaceRetriever {
    
    var delegate: FetchRacesDelegate?
    
//    // Could use [[CheckpointRace], [DestinationRace]] + flatmap?
//    func fetchAllRaces(forUser user: User) -> [Race] {
//        var allRaces: [Race] = []
//
//        fetchRaces(ofType: .checkpoint, forUser: user)
////        fetchRaces(ofType: .destination, forUser: user)
//
//        // delegate .loadAllRaces
//
//        return allRaces
//    }
    
    /// Fetches races of a specified type for a specified user
    func fetchRaces(ofType raceType: RaceType, forUser user: User) {
        var races: [Race] = []
        
        let key = raceType.rawValue
        let ref = Database.database().reference()        
        
        ref.child("users/\(user.uid)/races/\(key)").observe(.value) { (snapshot) in
            if !snapshot.exists() {
                // User has no races - return out
                return
            }
            
            let dbRaces = snapshot.value as! NSDictionary
            // Fetch only the race details and not the actual race - only fetch one (selected) race
            for race in dbRaces {
                // Tell group there is a pending block
                
                let raceId = race.key as! String
                let raceDetails = race.value as! NSDictionary
                
                // Fetch details and not the actual race - faster
                let raceName = raceDetails["name"] as! String
                let rating = raceDetails["rating"] as! Double
                let distance = raceDetails["distance"] as! Double
                let bestTime = raceDetails["bestTime"] as! Double
                
                // Create an initial race
                let race = Race(type: raceType, name: raceName, id: raceId, rating: rating, distance: distance, bestTime: bestTime)
                races.append(race)
            }
            self.delegate?.loadRaces(races, ofType: raceType)
        }
    }
    
    /// Fetches challenges made for the user
    func fetchChallenges(forUser profile: Profile) {
        var races: [Race] = []
        
        let ref = Database.database().reference()
        let userId = profile.getId()
        
        ref.child("users/\(userId)/races/challenge").observe(.value) { (snapshot) in
            if !snapshot.exists() {
                // User has no challenges - return out
                return
            }
            let challenges = snapshot.value as! NSDictionary
            
            // Keeps tracks of the number of pending blocks
            let group = DispatchGroup()
            
            // For each stored race convert it into a checkpoint race and store in this Profile
            for race in challenges {
                // Tell group there is a pending block
                group.enter()
                // Fetch only the details - then use the id to fetch the selected race
                let raceId = race.key as! String
                let raceDetails = race.value as! NSDictionary
                // TODO: Distance - stored in DB
                let raceName = raceDetails["name"] as! String
                let rating = raceDetails["rating"] as! Double
                let bestTime = raceDetails["bestTime"] as! Double
                
                // Make into challenge race
                let race = Race(type: .challenge, name: raceName, id: raceId, rating: rating, bestTime: bestTime)
                
                ref.child("races/challenge/\(raceId)").observe(.value) { (snapshot) in
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
                        race.addCheckpoint(point: point)
                        race.setRating(to: rating)
                    }
                    group.leave()
                    races.append(race)
                }
            }
            group.notify(queue: .main, execute: {
                // Once all calls are complete reload tableView data
                self.delegate?.loadRaces(races, ofType: .challenge)
            })
        }
    }
    
    /// Fetches all checkpoints contained in a race
    func fetchCheckpoints(forRace race: Race) {
        let key = race.getType().rawValue
        let ref = Database.database().reference()
        
        ref.child("races/\(key)/\(race.getId())").observeSingleEvent(of: .value, with: { (snapshot) in
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
                race.addCheckpoint(point: point)
            }
            self.delegate?.loadCheckpoints(race)
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    // getRace(ofType type: RaceType) -> [Race] {}
    
    func fetchAllUserRaces(_ user: User) {
        var races: [Race] = []
        
        fetchRaces(ofType: .checkpoint, forUser: user)
        delegate?.loadRaces(races, ofType: .all)
    }
}
