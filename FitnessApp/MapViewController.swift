//
//  MapViewController.swift
//  FitnessApp
//
//  Created by Josh Cotterell on 15/02/2018.
//  Copyright © 2018 Josh Cotterell. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation


class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    //    var race: CheckpointRace!
    
    let mapView: MKMapView = {
        let mv = MKMapView()
        mv.showsScale = true
        mv.showsPointsOfInterest = true
        mv.showsUserLocation = true
        mv.translatesAutoresizingMaskIntoConstraints = false
        return mv
    }()
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(mapView)
        mapView.anchorCenterSuperview(withWidth: view.frame.width, withHeight: view.frame.height)
        mapView.delegate = self
        
        // Initialising the map view
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
        // Show current user location on map
        findUserLocation()
    }
    
    @objc func findUserLocation() {
        guard let sourceCoords = locationManager.location?.coordinate else {
            print("Error finding user location")
            return
        }
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: sourceCoords, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    
    
}

