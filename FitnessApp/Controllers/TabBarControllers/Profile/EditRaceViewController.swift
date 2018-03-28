//
//  EditRaceViewController.swift
//  FitnessApp
//
//  Created by Josh Cotterell on 28/03/2018.
//  Copyright © 2018 Josh Cotterell. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

// ***** TODO: Change to race editor ******

class EditRaceViewController: GameMapViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        navigationItem.title = race?.getName()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveRace))
        
        // Add map components
        view.addSubview(mapView)
        let guide = view.layoutMarginsGuide
        addMapView(topAnchor: guide.topAnchor, bottom: guide.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, width: 0, height: 0)
        // TODO: Add map expansion (e.g. Tapping on the map should expand it)
        addUserLocationBtn()
        
        // Add all checkpoints to map. DONE
        // Allow them to be moved.
        // Allow changing of name.
        
        // Safely retrieve checkpoints and add the route to the mapView
        guard let checkpointCount = race?.getNumberOfCheckpoints() else { return }
        for ind in 1..<checkpointCount {
            guard let start = race?.checkpoints[ind-1].coordinate,
                let end = race?.checkpoints[ind].coordinate else { return }
            self.addDirections(from: start, to: end)
        }
    }
    
    override func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        // Do nothing in race editor
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        mapView.resignFirstResponder()
    }
    
    func addCircle(onCheckpoint point: MKPointAnnotation) {
        let circle = MKCircle(center: point.coordinate, radius: 100)
        mapView.add(circle)
    }
    
    @objc func saveRace() {
        // TODO: Update Firebase database with race deets.
        print("Save race")
    }
}

