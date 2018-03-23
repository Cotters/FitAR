//
//  RacePickerViewController.swift
//  FitnessApp
//
//  Created by Josh Cotterell on 28/02/2018.
//  Copyright © 2018 Josh Cotterell. All rights reserved.
//

import UIKit
import MapKit
import FirebaseAuth
import FirebaseDatabase

/// Used to fetch races and race data from Firebase
protocol FetchRacesDelegate {
    var races: [Race] { get set }
//    var typedRacesDict: [RaceType:[Race]] { get set}
    func loadRaces(_ races: [Race], ofType type: RaceType)
    func loadCheckpoints(_ race: Race)
}

class RacePickerViewController: CustomTableViewController, FetchRacesDelegate {
    
    // MARK: - View Properties
    let segmentedControl: UISegmentedControl = {
        let titles = ["Created", "Challenges", "POI"]
        let segmentedControl = UISegmentedControl(items: titles)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.tintColor = .systemBlue
        return segmentedControl
    }()
    
    // MARK: - Race properties
    var races: [Race] = []
    var raceType: RaceType!
    var raceTypes: [RaceType] = [.checkpoint, .challenge, .poi]
    var typedRacesDict: [RaceType:[Race]] = [:]
    
    // MARK: - Service properties
    var raceRetriever = RaceRetriever()
    var delegate: SelectRaceDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Adds tableView and an activityIndicator
        setupView()
        
        // Format nav bar
        let cancelBtn = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismissView))
        navigationItem.rightBarButtonItem = cancelBtn
        
        navigationItem.titleView = segmentedControl
        segmentedControl.addTarget(self, action: #selector(refreshView), for: .valueChanged)
        
        // Load races for the tableView
        raceRetriever.delegate = self
        raceRetriever.fetchRaces(ofType: raceType, forUser: user)
        raceRetriever.fetchRaces(ofType: .challenge, forUser: user)
        raceRetriever.fetchRaces(ofType: .poi, forUser: user)
        // TODO: Make a single function call that fetches all types.
    }
    
    @objc func dismissView() {
        dismiss(animated: true, completion: nil)
    }
    
    func loadRaces(_ races: [Race], ofType type: RaceType) {
        // TODO: Refresh view and display appropriate message if no races found.
        // ATM it shows spinner indefinitely.
        
        // Append races to races dictionary
        typedRacesDict[type] = races
        // Populate tableview
        refreshView()
    }
    
    func loadCheckpoints(_ race: Race) {
        delegate?.didSelectRace(race)
        dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let type = raceTypes[segmentedControl.selectedSegmentIndex]
        guard let races = typedRacesDict[type] else {
            return 0
        }
        return races.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RaceCell", for: indexPath) as! RaceTableViewCell
        
        // Safely retrieve any races, otherwise return an empty cell
        if let race = getRace(atIndex: indexPath.row) {
            cell.addRaceDetails(name: race.getName(), distance: race.getDistance(), rating: race.getRating())
            return cell
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Try fetch the checkpoints for that race
        if let race = getRace(atIndex: indexPath.row) {
            raceRetriever.fetchCheckpoints(forRace: race)
            return
        }
        // If race is nil display appropriate message
        showMessage(withTitle: "Error", message: "There was a problem retrieving that race. Please try another.")
    }
    
    func getRace(atIndex index: Int) -> Race? {
        let type = raceTypes[segmentedControl.selectedSegmentIndex]
        guard let races = typedRacesDict[type] else {
            return nil
        }
        return races[index]
    }
}
