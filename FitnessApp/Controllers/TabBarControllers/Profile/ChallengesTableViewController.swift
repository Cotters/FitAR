//
//  ChallengesTableViewController.swift
//  FitnessApp
//
//  Created by Bridget Carroll on 28/03/2018.
//  Copyright © 2018 Josh Cotterell. All rights reserved.
//

import UIKit

class ChallengesTableViewController: CustomTableViewController, FetchRacesDelegate {
    
    var challenges: [Race] = []
    
    // MARK: - Service properties
    var raceService = RaceService()
    var delegate: SelectRaceDelegate?
    
    override func viewDidLoad() {
        // Add tableView and spinner
        setupView()
        
        // Setup NavBar and editing
        navigationItem.title = "Challenges"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(toggleEdit))
        // Shows the user how to cancel any modifications made in the editRaceVC
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        
        // Load races for the tableView
        raceService.delegate = self
        raceService.fetchRaces(ofType: .challenge, for: user)
    }
    
    @objc func toggleEdit() {
        tableView.setEditing(!tableView.isEditing, animated: true)
        navigationItem.rightBarButtonItem?.title = tableView.isEditing ? "Done" : "Edit"
    }
    
    // MARK: - FetchRacesDelegate methods
    func loadRaces(_ races: [Race], ofType type: RaceType) {
        self.challenges = races
    }
    
    func loadCheckpoints(for race: Race) {
        // ** For preview? - Accept or reject scene?
        print("Wooo!")
    }
    
    // MARK: - TableViewDelegate methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return challenges.count
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RaceCell", for: indexPath) as! RaceTableViewCell
        
        let race = challenges[indexPath.row]
        cell.addRaceDetails(race)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let challenge = challenges[indexPath.row]
        raceService.fetchCheckpoints(for: challenge)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Remove from Firebase
            let challenge = challenges[indexPath.row]
            self.raceService.delete(race: challenge, for: user)
            
            // Remove from tableView
            self.challenges.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}
