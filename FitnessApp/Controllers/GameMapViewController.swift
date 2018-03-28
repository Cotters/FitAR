//
//  GameMapViewController.swift
//  FitnessApp
//
//  Created by Josh Cotterell on 04/03/2018.
//  Copyright © 2018 Josh Cotterell. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

protocol SelectRaceDelegate {
    func didSelectRace(_ race: Race)
}

class GameMapViewController: UserContainedViewController, CLLocationManagerDelegate, MKMapViewDelegate, SelectRaceDelegate {
    
    let mapView: MKMapView = {
        let mv = MKMapView()
        mv.showsScale = true
        mv.showsCompass = true
        mv.showsPointsOfInterest = true
        mv.showsUserLocation = true
        return mv
    }()
    
    let raceSelectBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("Select a race", for: .normal)
        btn.backgroundColor = .systemBlue
        btn.tintColor = .white
        btn.addTarget(self, action: #selector(showRacePicker), for: .touchUpInside)
        return btn
    }()
    
    let userLocationBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(#imageLiteral(resourceName: "user_location"), for: .normal)
        btn.addTarget(self, action: #selector(findUserLocation), for: .touchUpInside)
        return btn
    }()
    
    var race: Race? {
        didSet {
            if race != nil {
                guard let startPin = race?.getStart() else { return }
                showUserDirections(to: startPin)
            }
        }
    }
    
    var currentCheckpointCount = 0
    var currentCheckpoint: MKPointAnnotation?
    
    let locationManager = CLLocationManager()
    
    // Used to animate the select race and progress race buttons
    var raceSelectBtnAnchor: NSLayoutConstraint!
    var raceSelectBtnVisible = true
    
    var timer: Date!
    var raceTime: Double!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Delegates
        mapView.delegate = self
        
        // Initialising the mapView and locationManager with correct permissions
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
        // View Setup
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        
        // Show current user location on map
        DispatchQueue.main.async {
            self.findUserLocation()
        }
    }
    
    // MARK: - Adding subview methods
    func addMapView() {
        // Spans full view
        view.addSubview(mapView)
        let guide = view.safeAreaLayoutGuide
        mapView.anchor(guide.topAnchor, bottom: guide.bottomAnchor, left: guide.leftAnchor, right: guide.rightAnchor, topConstant: 0, bottomConstant: 0, leftConstant: 0, rightConstant: 0, width: 0, height: 0)
    }
    
    func addMapView(topAnchor: NSLayoutYAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil, left: NSLayoutXAxisAnchor? = nil, right: NSLayoutXAxisAnchor? = nil, width: CGFloat, height: CGFloat) {
        view.addSubview(mapView)
        mapView.anchor(topAnchor, bottom: bottom, left: left, right: right, topConstant: 0, bottomConstant: 0, leftConstant: 0, rightConstant: 0, width: width, height: height)
    }
    
    func addRaceSelectBtn() {
        // Used to animate the 'select race' button in and out of view
        view.addSubview(raceSelectBtn)
        raceSelectBtn.anchor(nil, bottom: nil, left: nil, right: nil, topConstant: 0, bottomConstant: 0, leftConstant: 0, rightConstant: 0, width: view.frame.width*0.75, height: 30)
        raceSelectBtnAnchor = raceSelectBtn.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -15)
        NSLayoutConstraint.activate([raceSelectBtnAnchor])
        raceSelectBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    func addUserLocationBtn() {
        // Add button to zoom in on user location
        view.addSubview(userLocationBtn)
        userLocationBtn.anchor(nil, bottom: view.bottomAnchor, left: nil, right: view.rightAnchor, topConstant: 0, bottomConstant: -80, leftConstant: 0, rightConstant: -10, width: 40, height: 40)
    }
    
    // MARK: - Toggle methods
    func toggleRaceSelectBtn(show: Bool) {
        // Show/Hide the select race button using animation
        if show && !raceSelectBtnVisible {
            self.raceSelectBtnAnchor.constant = -15
            raceSelectBtnVisible = true
        } else if !show && raceSelectBtnVisible {
            self.raceSelectBtnAnchor.constant = 50
            raceSelectBtnVisible = false
        }
        
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - Button selector methods
    @objc func findUserLocation() {
        guard let sourceCoords = locationManager.location?.coordinate else {
            // Request user location sharing
            if CLLocationManager.authorizationStatus() == .denied {
                showSettingsAlert(withMessage: "You must enable location sharing to use this app.")
            }
            print("Error finding user location")
            return
        }
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: sourceCoords, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    @objc func showRacePicker() {
        let racePickerController = RacePickerViewController()
        racePickerController.raceType = .checkpoint // TODO: Use checkpoint by default
        racePickerController.delegate = self
        self.present(UINavigationController(rootViewController: racePickerController), animated: true, completion: nil)
    }
    
    // MARK: - Race Methods
    func didSelectRace(_ race: Race) {
        self.race = race
        // Hide the race selection button
        toggleRaceSelectBtn(show: false)
    }
    
    func showUserDirections(to destPin: MKPointAnnotation) {
        // Show directions to the start line
        guard let userLoc = locationManager.location else {
            // TODO: Figure out what to do in this event
            print("Error finding user location")
            return
        }
        // Remove all current pins/lines
        mapView.clear()
        addDirections(from: userLoc.toAnnotation(), to: destPin)
    }
    
    @objc func nextCheckpoint() {
        // Progress the race
        currentCheckpointCount += 1
        
        if currentCheckpointCount == 1 {
            // Start timer only when user has arrived at the start of the race
            timer = Date()
        }
        
        // Get the next checkpoint as pin
        guard let checkpoint = race?.getCheckpoint(atIndex: currentCheckpointCount) else {
            // Check for finish
            checkFinish()
            return
        }
        // Update current checkpoint - used for directions
        self.currentCheckpoint = checkpoint
        
        // Show directions from user to next checkpoint
        showUserDirections(to: checkpoint)
        
        // Monitor for arrival at next checkpoint
        monitorCheckpoint()
    }
    
    func addDirections(from start: MKPointAnnotation, to destination: MKPointAnnotation) {
        // Add the current checkpoint to the map
        mapView.addAnnotation(destination)
        
        // Get source and destination info for direction request
        let sourceCoords = start.getLocation()
        let destCoords = destination.getLocation()
        let sourceItem = MKMapItem(placemark: MKPlacemark(coordinate: sourceCoords.coordinate))
        let destItem = MKMapItem(placemark: MKPlacemark(coordinate: destCoords.coordinate))
        
        // Show direction on map
        let dirRequest = MKDirectionsRequest()
        dirRequest.source = sourceItem
        dirRequest.destination = destItem
        dirRequest.transportType = .walking
        
        // Perform a direction request
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
    
    /// Start monitoring the current checkpoint.
    func monitorCheckpoint() {
        guard let race = self.race,
            let destCheckpoint = race.getCheckpoint(atIndex: currentCheckpointCount) else { return }
        let region = CLCircularRegion(center: destCheckpoint.coordinate, radius: 10, identifier: "")
        locationManager.startMonitoring(for: region)
    }
    
    func checkFinish() {
        guard let race = self.race else { return }
        // If the user has progressed to the end or past the race, finish.
        if (currentCheckpointCount >= race.getNumberOfCheckpoints()) {
            raceComplete()
            // TODO: Show a view that displays: Best time, Current time, # of times completed etc.
            return
        }
    }
    
    /// Stores best time and resets the scene
    func raceComplete() {
        // Store best time
        raceTime  = Date().timeIntervalSince(timer)
        race?.updateBestTime(to: raceTime, forUserWithId: user.uid)
        // Each scene will do this differently, so call their method
        resetScene()
    }
    
    /// Resets the scene ready for a new race
    func resetScene() {
        mapView.clear()
        // Reset the view and race
        toggleRaceSelectBtn(show: true)
        currentCheckpointCount = 0
        race = nil
    }
    
    // MARK: - Map & Location Methods
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        // Draw a line on the map - from source to destination
        if overlay is MKPolyline {
            let render = MKPolylineRenderer(overlay: overlay)
            render.strokeColor = .systemBlue
            render.lineWidth = 5
            return render
        } else if overlay is MKCircle {
            let renderer = MKCircleRenderer(overlay: overlay)
            renderer.fillColor = UIColor.black.withAlphaComponent(0.1)
            renderer.strokeColor = .systemBlue
            renderer.lineWidth = 2
            return renderer
        }
        return MKOverlayRenderer()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for region in manager.monitoredRegions {
            if let cRegion = region as? CLCircularRegion {
                if cRegion.contains(manager.location!.coordinate) && race != nil {
                    // Progress the race
                    self.nextCheckpoint()
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        // User entered a checkpoint -
        showMessage(withTitle: "Congrats", message: "You arrived at a checkpoint!")
    }
    
}
