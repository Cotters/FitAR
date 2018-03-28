//
//  RaceCreationController.swift
//  FitnessApp
//
//  Created by Josh Cotterell on 10/02/2018.
//  Copyright © 2018 Josh Cotterell. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase

class RaceCreationController: GameMapViewController {
    
    let addBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(#imageLiteral(resourceName: "plus_icon"), for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    var raceType: RaceType!
    var raceName: String!
    
    var ref: DatabaseReference!

    // Keeps track of the race locally
    var checkpoints: [MKPointAnnotation] = []
    var checkpoint: MKPointAnnotation!
    var totalDistance = 0.0
    
    // Used to animate the addBtn
    var addBtnRightAnchor: NSLayoutConstraint!
    var addBtnVisible = false
    
    var delegate: ChallengeUserDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Total: 0 meters"
        
        ref = Database.database().reference()
        
        // Add relevant items
        addMapView()
        addUserLocationBtn()
        
        // Ask the user to name the race
        let alert = UIAlertController(title: "Race name", message: "Please give the race a name", preferredStyle: .alert)
        alert.addTextField { (textfield) in
            textfield.placeholder = "Newcastle Uni Race"
            textfield.autocapitalizationType = UITextAutocapitalizationType.sentences
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {(action) in
            // Dismiss view if name is cancelled
            self.navigationController?.popViewController(animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Create", style: .default, handler: { (action) in
            // Use the textfield text to name the race
            guard let tf = alert.textFields?.first else { return }
            self.raceName = tf.text!
        }))
        self.present(alert, animated: true, completion: nil)
        
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(completeRace))
        
        
        view.addSubview(addBtn)
        // Used to animate the button in and out of view
        addBtnRightAnchor = addBtn.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 80)
        NSLayoutConstraint.activate([addBtnRightAnchor])
        
        addBtn.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
        addBtn.widthAnchor.constraint(equalToConstant: 50).isActive = true
        addBtn.heightAnchor.constraint(equalToConstant: 50).isActive = true
        addBtn.addTarget(self, action: #selector(addCheckpoint), for: .touchUpInside)
        

        // Add pins/checkpoints
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(addPin(sender:)))
        mapView.addGestureRecognizer(longPressGesture)
    }
    
    @objc func addPin(sender: UILongPressGestureRecognizer) {
        // Only show the add button (allowing the user to add a checkpoint) when a point has been placed
        toggleAddBtn(show: true)
        
        let location = sender.location(in: mapView)
        let coord = mapView.convert(location, toCoordinateFrom: mapView)
        
        // Remove old pins
        mapView.removeAnnotations(mapView.annotations)
        
        // Place marker on map
        let pin = MKPointAnnotation()
        pin.coordinate = coord
        pin.title = "Checkpoint \(checkpoints.count)"
        mapView.addAnnotation(pin)
        
        // Keep track of the current checkpoint
        checkpoint = pin
    }
    
    func toggleAddBtn(show: Bool) {
        // Show/Hide the add checkpoint button using animation
        if show && !addBtnVisible {
            self.addBtnRightAnchor.constant = -20
            addBtnVisible = true
        } else if !show && addBtnVisible {
            self.addBtnRightAnchor.constant = 80
            addBtnVisible = false
        }
        
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func addCheckpoint() {
        toggleAddBtn(show: false)
        
        // Safely check the total distance
        if let last = checkpoints.last {
            // Show total distance
            totalDistance += Race.getDistance(from: last, to: checkpoint)
            navigationItem.title = "Total: \(Int(totalDistance)) meters"
        }
        
        // Add checkpoint to local array of checkpoints
        checkpoints.append(checkpoint)
        
        // Challenges and destination races only have 2 checkpoints
        if (raceType == .challenge && checkpoints.count == 2) {
            completeRace()
        } else if raceType == .poi {
            
        }
    }
    
    // Not used - is it useful?
    func drawLine(from start: MKPointAnnotation, to finish: MKPointAnnotation) {
        
        let source = MKMapItem(placemark: MKPlacemark(coordinate: start.coordinate))
        let dest = MKMapItem(placemark: MKPlacemark(coordinate: finish.coordinate))
        
        let dirRequest = MKDirectionsRequest()
        dirRequest.source = source
        dirRequest.destination = dest
        dirRequest.transportType = .walking
        
        let directions = MKDirections(request: dirRequest)
        directions.calculate { (response, error) in
            guard let response = response else {
                if error != nil {
                    print(error!)
                }
                return
            }
            
            guard let route = response.routes.first else { return }
            self.mapView.add(route.polyline, level: .aboveRoads)
            
            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegionForMapRect(rect), animated: true)
        }
    }
    
    @objc func completeRace() {
        if (raceType == .checkpoint && checkpoints.count < 2) || checkpoints.count == 0 {
            let exitAction = UIAlertAction(title: "Exit", style: .default, handler: { _ in
                    // Dismiss view after user confirms a nil race
                    self.navigationController?.popViewController(animated: true)
            })
            showAlert(withTitle: "Race is incomplete", message: "Not enought points to save the race. Do you wish to exit?", actions: [exitAction], style: .alert)
            return
        }
        
        // Save the race - note: raceId will be set later using a random string
        let race = Race(type: raceType, name: raceName, checkpoints: checkpoints)
        // Check if challenge, else store in the user's profile
        if raceType == .challenge {
            // Return to challenged user's profile
            delegate?.storeChallenge(race)
        } else {
            // Store race for current user
            race.store(forUserWithId: user.uid)
        }
        // Return out
        self.navigationController?.popViewController(animated: true)
    }
    
}
