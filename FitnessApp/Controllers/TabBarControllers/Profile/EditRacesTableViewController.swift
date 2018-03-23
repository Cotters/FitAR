//
//  EditRacesTableViewController.swift
//  FitnessApp
//
//  Created by Josh Cotterell on 22/03/2018.
//  Copyright © 2018 Josh Cotterell. All rights reserved.
//

import UIKit

class EditRacesTableViewController: CustomTableViewController, FetchRacesDelegate {
    
    var races: [Race] = []
    
    // MARK: - Service properties
    var raceRetriever = RaceRetriever()
    var delegate: SelectRaceDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Add tableView and spinner
        setupView()
        // Setup NavBar and editing
        navigationItem.title = "Edit Races"
        navigationItem.rightBarButtonItem = editButtonItem
        isEditing = false
        
        // Load races for the tableView
        raceRetriever.delegate = self
        raceRetriever.fetchRaces(ofType: .checkpoint, forUser: user)
        raceRetriever.fetchRaces(ofType: .challenge, forUser: user) // or not? Can deny them
        raceRetriever.fetchRaces(ofType: .poi, forUser: user)
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        if(editing && !isEditing) {
            tableView.setEditing(true, animated: true)
        }else{
            tableView.setEditing(false, animated: true)
        }
    }
    
    func loadRaces(_ races: [Race], ofType type: RaceType) {
        self.races.append(contentsOf: races)
        refreshView()
    }
    
    func loadCheckpoints(_ race: Race) {
        delegate?.didSelectRace(race)
        // TODO: Present race edit view
    }
    
    // MARK: - TableView methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return races.count
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RaceCell", for: indexPath) as! RaceTableViewCell
        
        let race = races[indexPath.row]
        cell.addRaceDetails(name: race.getName(), distance: race.getDistance(), rating: race.getRating())
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO: Allow edit race
        print(indexPath.item)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.races.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    
}
