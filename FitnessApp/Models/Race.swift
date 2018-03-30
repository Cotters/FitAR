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

protocol CheckpointRace {
    var type: RaceType { get }
    var name: String { get set }
    var id: String { get set }
    var rating: Double { get set }
    var bestTime: Double { get set }
    var distance: Double { get set }
    var checkpoints: [MKPointAnnotation] { get set }
}

/// A collection of real world checkpoints the user must get to in order to finish.
final class Race: CheckpointRace {
    
    // MARK: - Properties
    private var raceType: RaceType
    var type: RaceType {
        return raceType
    }
    var name: String
    var id: String
    var rating: Double
    var bestTime: Double
    var distance: Double
    var checkpoints: [MKPointAnnotation] {
        didSet {
            distance = calculateTotalDistance()
        }
    }
 
    let raceService = RaceService()
    
    // MARK: - Init Methods
    init(type: RaceType, name: String, id: String = "", rating: Double = 0, checkpoints: [MKPointAnnotation] = [], distance: Double = 0, bestTime: Double = 0) {
        self.raceType = type
        self.name = name
        self.id = id
        self.rating = rating
        self.bestTime = bestTime
        self.distance = distance
        self.checkpoints = checkpoints
    }
    
    // MARK: - Getters & Setters
    final func addCheckpoint(_ point: MKPointAnnotation) {
        checkpoints.append(point)
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
    
    func calculateTotalDistance() -> Double {
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
    
    func getIndexOf(checkpoint: MKPointAnnotation) -> Int? {
        return checkpoints.index(of: checkpoint)
    }
    
    
    // MARK: - Firebase Database Methods
    func store(forUserWithId userId: String) {
        raceService.store(race: self, userId: userId)
    }
    
    func updateBestTime(to time: Double, forUserWithId userId: String) {
        // Only update if it's better
        if time < bestTime {
            raceService.save(time: time, for: self, using: userId)
        }
    }
}
