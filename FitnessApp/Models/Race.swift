//
//  Race.swift
//  FitnessApp
//
//  Created by Josh Cotterell on 28/02/2018.
//  Copyright © 2018 Josh Cotterell. All rights reserved.
//

import UIKit
import MapKit

/// Various races that the user can make and take part in.
enum RaceType: String {
    case checkpoint
    case challenge
    case poi // Point of interest
    case ghost // Show personal best run using the jet or show the pace you have to run to make a certain time
    case hunt // Search for items along a route using AR camera. - might have to change visibility / hard to do
    case all // All race types
}

/// A collection of real world checkpoints the user must get to in order to finish.
class Race: NSObject {
    
    // MARK: - Properties
    // TODO: Make optional and safely return
    var type: RaceType!
    var name: String!
    var id: String!
    var rating: Double?
    var checkpoints: [MKPointAnnotation] = []
    var bestTime: Double?
    var distance: Double?
    
    let raceService = RaceService()
    
    
    // MARK:- Init Methods
    init(type: RaceType, name: String, id: String = "", rating: Double = 0, checkpoints: [MKPointAnnotation] = [], distance: Double = 0, bestTime: Double = 0) {
        super.init()
        self.type = type
        self.name = name
        self.id = id
        self.rating = rating
        self.bestTime = bestTime
        self.checkpoints = checkpoints
        self.distance = distance <= 0 ? self.getTotalDistance() : distance
    }
    
    // MARK:- Getters & Setters
    final func addCheckpoint(point: MKPointAnnotation) {
        checkpoints.append(point)
    }
    
    final func setType(to type: RaceType) {
        self.type = type
    }
    
    final func getType() -> RaceType {
        return type
    }
    
    final func setName(to name: String) {
        self.name = name
    }
    
    final func getName() -> String {
        return name
    }
    
    final func setId(to id: String) {
        self.id = id
    }
    
    final func getId() -> String {
        return id
    }
    
    final func setRating(to score: Double) {
        self.rating = score
    }
    
    final func getRating() -> Double {
        guard let rating = self.rating else {
            return 0
        }
        return rating
    }
    
    final func setDisntance(_ distance: Double) {
        self.distance = distance
    }
    
    final func getDistance() -> Double {
        guard let distance = self.distance else {
            return 0
        }
        return distance
    }
    
    func getStart() -> MKPointAnnotation? {
        return checkpoints.first
    }
    
    func getEnd() -> MKPointAnnotation? {
        return checkpoints.last
    }
    
    final func setCheckpoints(_ checkpoints: [MKPointAnnotation]) {
        self.checkpoints = checkpoints
    }
    
    final func getCheckpoints() -> [MKPointAnnotation] {
        return checkpoints
    }
    
    func getNumberOfCheckpoints() -> Int {
        return checkpoints.count
    }
    
    final func getLocation(ofPoint point: MKPointAnnotation) -> CLLocation {
        return CLLocation(latitude: point.coordinate.latitude, longitude: point.coordinate.longitude)
    }
    
    final func getDistance(from start: MKPointAnnotation?, to end: MKPointAnnotation) -> Double {
        // If start is null then we assume the end is the first point - so return 0
        guard let start = start else { return 0.0 }
        let p1 = getLocation(ofPoint: start)
        let p2 = getLocation(ofPoint: end)
        return p1.distance(from: p2)
    }
    
    final func getDistanceFromLastPoint(to dest: MKPointAnnotation) -> Double {
        guard let lastPoint = checkpoints.last else { return 0 }
        return getDistance(from: lastPoint, to: dest)
    }
    
    func getTotalDistance() -> Double {
        var distance: Double = 0
        
        if checkpoints.count > 1 {
            for ind in 1..<checkpoints.count {
                let dist = getDistance(from: checkpoints[ind-1], to: checkpoints[ind])
                distance += dist
            }
        }
        return distance
    }
    
    func getCheckpoint(atIndex index: Int) -> MKPointAnnotation? {
        // Safely return last checkpoint - otherwise nil
        return checkpoints.indices.contains(index) ? checkpoints[index] : nil
    }
    
    func getIndexOf(checkpoint point: MKPointAnnotation) -> Int {
        return checkpoints.index(of: point)!
    }
    
    
    // MARK:- Firebase Database Methods
    func store(forUserWithId userId: String) {
        raceService.store(race: self, userId: userId)
    }
    
    func updateBestTime(to time: Double, forUserWithId userId: String) {
        // Only update if it's better
        if let bestTime = self.bestTime {
            if time < bestTime {
                raceService.saveTime(for: self, forUserWith: userId, time: time)
            }
        }
    }
    
    // MARK: - Static helper functions
    // (mainly for race creator)
    static func getDistance(from start: MKPointAnnotation?, to end: MKPointAnnotation) -> Double {
        // If start is null then we assume the end is the first point - so return 0
        guard let start = start else { return 0.0 }
        let p1 = getLocation(ofPoint: start)
        let p2 = getLocation(ofPoint: end)
        return p1.distance(from: p2)
    }
    
    static func getLocation(ofPoint point: MKPointAnnotation) -> CLLocation {
        return CLLocation(latitude: point.coordinate.latitude, longitude: point.coordinate.longitude)
    }
    
}
