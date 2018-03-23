//
//  RaceViewController.swift
//  FitnessApp
//
//  Created by Josh Cotterell on 15/02/2018.
//  Copyright © 2018 Josh Cotterell. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

// ***** TODO: Change to race editor ******

class RaceViewController: MapViewController {
    
    var race: Race!
    var currentCheckpoint = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = race.name
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Start", style: .plain, target: self, action: #selector(nextCheckpoint))
        
        // Show directions to start of race
        guard let start = race.getStart() else { return }
        showDirectionsToStart(checkpoint: start)
        
        // Init race with start position and first checkpoint
//        nextCheckpoint()
    }
    
    func showDirectionsToStart(checkpoint startPin: MKPointAnnotation) {
        // Show directions to the start line
        guard let userCoords = locationManager.location?.coordinate else {
            print("Error finding user location")
            return
        }
        let sourcePlacemark = MKPlacemark(coordinate: userCoords)
        let destPlacemark = MKPlacemark(coordinate: startPin.coordinate)
        mapView.addAnnotation(startPin)
        
        let dirRequest = MKDirectionsRequest()
        dirRequest.source = MKMapItem(placemark: sourcePlacemark)
        dirRequest.destination = MKMapItem(placemark: destPlacemark)
        dirRequest.transportType = .walking // Check what the user wants - running or cycling
        
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
    
    @objc func nextCheckpoint() {        
        // Remove all current pins/lines
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
        
        // Check for finish
        if (currentCheckpoint+1 >= race.getNumberOfCheckpoints()) {
            // Race is Done
            print("race finito")
            // Show a view that displays: Best time, Current time, # of times completed etc.
            return
        }
        
        // Get the next checkpoint as pin and add pins/lines
        guard let start = race.getCheckpoint(atIndex: currentCheckpoint) else { return }
        guard let dest = race.getCheckpoint(atIndex: currentCheckpoint+1) else { return }
        addDirections(start: start, destination: dest)
        
        // Progress the race
        currentCheckpoint += 1
    }
    
    func addDirections(start: MKPointAnnotation, destination: MKPointAnnotation) {
        mapView.addAnnotation(start)
        mapView.addAnnotation(destination)
        
        let sourceCoords = race.getLocation(ofPoint: start)
        let destCoords = race.getLocation(ofPoint: destination)
        
        let sourceItem = MKMapItem(placemark: MKPlacemark(coordinate: sourceCoords.coordinate))
        let destItem = MKMapItem(placemark: MKPlacemark(coordinate: destCoords.coordinate))
        
        // Show direction on map
        let dirRequest = MKDirectionsRequest()
        dirRequest.source = sourceItem
        dirRequest.destination = destItem
        dirRequest.transportType = .walking
        
        let directions = MKDirections(request: dirRequest)
        directions.calculate { (response, error) in
            guard let response = response else {
                if error != nil {
                    print(error!)
                }
                return
            }
            
            // Add the route to the MapView
            guard let route = response.routes.first else { return }
            self.mapView.add(route.polyline, level: .aboveRoads)
        }
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        // Called whenever the user moves - so check if at next checkpoint
        print("user moved")
        guard let destCheckpoint = race.getCheckpoint(atIndex: currentCheckpoint) else { return }
        let region = CLCircularRegion(center: destCheckpoint.coordinate, radius: 50, identifier: "CzechPoint")
        locationManager.startMonitoring(for: region)
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        // User entered a checkpoint?
        print("arrived at checkpoint")
        let alert = UIAlertController(title: "Arrived at checkpoint", message: "Nice going", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Continue", style: .default, handler: { _ in
            // Dismiss view after user confirms a nil race
            self.nextCheckpoint()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        mapView.resignFirstResponder()
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        // Draw a line on the map - from source to destination
        let render = MKPolylineRenderer(overlay: overlay)
        render.strokeColor = .cyan
        render.lineWidth = 5
        
        return render
    }
    
    func addCircle(onCheckpoint point: MKPointAnnotation) {
        let circle = MKCircle(center: point.coordinate, radius: 100)
        mapView.add(circle)
    }
    
}
