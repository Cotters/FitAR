//
//  HomeViewController.swift
//  FitnessApp
//
//  Created by Josh Cotterell on 24/11/2017.
//  Copyright © 2017 Josh Cotterell. All rights reserved.
//

import UIKit
import CoreMotion
import CoreLocation
import HealthKit
import FirebaseAuth

protocol UserDataSource {
    var steps: Int { get set }
    var distance: Int { get set }
    var calories: Int { get set }
    var time: Int { get set }
}

struct UserData: UserDataSource {
    var steps: Int
    var distance: Int
    var calories: Int
    var time: Int
}

class HomeViewController: UserContainedViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, CLLocationManagerDelegate {
    
    var collectionView: UICollectionView!
    
    let pedometer = CMPedometer()
    
    var midnightToday: Date!
    
    let healthStore = HKHealthStore()
    
    // Cell data
    // Change value to string: e.g. 0.19 miles, 429 kcals, 11 mins etc.
    var userInfo: [[String:String]] = [["Steps":"0"], ["Distance":"10 mi"], ["Calories":"0 kcals"], ["Time":"0"]] {
        didSet {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    let icons = [#imageLiteral(resourceName: "walking_icon"), #imageLiteral(resourceName: "distance_icon"), #imageLiteral(resourceName: "calories_icon"), #imageLiteral(resourceName: "timer_icon")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .lightGrey
        navigationItem.title = "Today"
        
        // CollectionView Setup
        let flowLayout = UICollectionViewFlowLayout()
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        collectionView.register(HomeCollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        self.view.addSubview(collectionView)
        
        var cal = Calendar.current
        var comps = cal.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date())
        comps.hour = 0
        comps.minute = 0
        comps.second = 0
        let timeZone = NSTimeZone.system
        cal.timeZone = timeZone
        midnightToday = cal.date(from: comps)!

        // Ensure the user is ok with using HealthKit
        if authoriseHealthKit() {
            // Fetch some data
            print("Fetching steps and distance")
            fetchWalkRunDistance()
            fetchStepCount()
        }
    }
    
    // MARK: - CollectionViewDelegate methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userInfo.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath as IndexPath) as! HomeCollectionViewCell
        
        let dict = userInfo[indexPath.row] as [String:String]
        for (text,data) in dict {
            cell.cellLabel.text = text + ": \(data)"
            cell.iconImageView.image = icons[indexPath.row]
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 25.0
        let width = collectionView.frame.size.width - padding
        return CGSize(width: width/2, height: width/2)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    }
    
}

/// Health Kit Data
extension HomeViewController {
    
    /// Checks if the user has authorised the use of their HealthKit data being used.
    func authoriseHealthKit() -> Bool {
        var isAuthorised = true
        // Seek authorization for HealthKit data.
        healthStore.handleAuthorizationForExtension { (authorised, error) in
            if authorised {
                // State the health data type(s) we want to read from HealthKit.
                let healthDataToRead = Set(arrayLiteral: HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!, HKObjectType.quantityType(forIdentifier: .stepCount)!)
                
                // State the health data type(s) we want to write from HealthKit.
                let healthDataToWrite = Set(arrayLiteral: HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!)
                
                self.healthStore.requestAuthorization(toShare: healthDataToWrite, read: healthDataToRead, completion: { (success, error) in
                    if success {
                        if error != nil {
                            print(error?.localizedDescription ?? "Error has occured while requesting authorisation to read and write data to HealthKit.")
                        }
                    }
                })
            } else {
                // HealthKit has not been authorised.
                if error != nil {
                    print(error?.localizedDescription ?? "Error: User has not authorised use of HealthKit.")
                }
                self.showMessage(withTitle: "Unable to monitor activity", message: "You have denied access to HealthKit. Please enable access to monitor your activity.")
            }
        }
        // Final check to swift bool or show error message
        if !HKHealthStore.isHealthDataAvailable() {
            isAuthorised = false
            // Send user to settings
            let healthSettingsURL =  URL(string: "App-Prefs:root=Privacy&path=Health")
            showSettingsAlert(withMessage: "HealthKit must be enabled to use the app.", and: healthSettingsURL)
        }
        return isAuthorised
    }
    
    /// Executes a query that returns the distance run in miles
    func fetchWalkRunDistance() {
        var distance: Double = 0
        let date = NSDate() as Date
        let cal = Calendar(identifier: Calendar.Identifier.gregorian)
        let newDate = cal.startOfDay(for: date)
        
        let predicate = HKQuery.predicateForSamples(withStart: newDate as Date, end: NSDate() as Date, options: .strictStartDate)

        let query = HKStatisticsQuery(quantityType: HKSampleType.quantityType(forIdentifier: .distanceWalkingRunning)!, quantitySamplePredicate: predicate, options: [.cumulativeSum]) { (query, statistics, error) in
            if error != nil {
                print(error?.localizedDescription ?? "Error occurec retrieving HealthKit distance run/walked data.")
            }
            if let quantity = statistics?.sumQuantity() {
                distance = quantity.doubleValue(for: .mile())
                let distString = String(format: "%.2f", distance)
                self.userInfo[1]["Distance"] = distString + " mi"
            }
        }
        healthStore.execute(query)
    }
    
    func fetchStepCount() {
        var steps: Double = 0
        
        let date = NSDate() as Date
        let cal = Calendar(identifier: Calendar.Identifier.gregorian)
        let newDate = cal.startOfDay(for: date)
        
        let predicate = HKQuery.predicateForSamples(withStart: newDate as Date, end: NSDate() as Date, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: HKSampleType.quantityType(forIdentifier: .stepCount)!, quantitySamplePredicate: predicate, options: [.cumulativeSum]) { (query, statistics, error) in
            if error != nil {
                print(error?.localizedDescription ?? "Error occurec retrieving HealthKit distance run/walked data.")
            }
            
            if let quantity = statistics?.sumQuantity() {
                steps = quantity.doubleValue(for: .count())
                self.userInfo[0]["Steps"] = "\(Int(steps))"
            }
        }
        healthStore.execute(query)
    }
}
