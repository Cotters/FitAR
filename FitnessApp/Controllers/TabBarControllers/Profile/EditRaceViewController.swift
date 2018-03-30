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

class EditRaceViewController: GameMapViewController {
    
    var checkpoints: [MKPointAnnotation]?
    var selectedPoint: MKPointAnnotation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        navigationItem.title = race?.name ?? "Editor"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveRace))
        
        // Add map components
        view.addSubview(mapView)
        let guide = view.layoutMarginsGuide
        addMapView(topAnchor: guide.topAnchor, bottom: guide.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, width: 0, height: 0)
        addUserLocationBtn()
        
        // Safely retrieve checkpoints and store a local copy
        checkpoints = race?.checkpoints
        // Add the race route to the mapView
        drawRoute()
    }
    
    /// Add directions from start to finish to the map
    func drawRoute() {
        // Remove all current pins/lines
        mapView.clear()
        // Safely unwrap checkpoints to ensure that some exist
        guard let checkpoints = checkpoints else { return }
        let checkpointCount = checkpoints.count
        // Add the start
        mapView.addAnnotation(checkpoints[0])
        // Add pins and route between pins
        for ind in 1..<checkpointCount {
            let start = checkpoints[ind-1]
            let end = checkpoints[ind]
            self.addDirections(from: start, to: end)
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        selectedPoint = view.annotation as? MKPointAnnotation
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Retrieve the location the user is tracing to
        guard let touch = touches.first else { return }
        let location = touch.location(in: mapView)
        let newCoord = mapView.convert(location, toCoordinateFrom: mapView)
        // Move the point
        selectedPoint?.coordinate = newCoord
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Safely unwrap the point being moved
        guard let selectedPoint = self.selectedPoint else { return }
        // Place annotation
        mapView.deselectAnnotation(selectedPoint, animated: true)
        // Redraw new route
        drawRoute()
        // Reset point
        self.selectedPoint = nil
    }
    
    override func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        // Overrride this method because we don't need to monitor in editor mode.
    }
    
    @objc func saveRace() {
        // Update race in Firebase database.
        guard let oldRace = self.race else { return }
        let raceService = RaceService()
        raceService.update(oldRace, forUser: user)
    }
    
    
}