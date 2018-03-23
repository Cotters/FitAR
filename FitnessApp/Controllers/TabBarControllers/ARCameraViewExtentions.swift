//
//  ARCameraViewExtentions.swift
//  FitnessApp
//
//  Created by Josh Cotterell on 21/03/2018.
//  Copyright © 2018 Josh Cotterell. All rights reserved.
//

import UIKit
import MapKit

/// Represents a step as a location with coordordinates and a title
final class DirectionStep: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(coordinate: CLLocationCoordinate2D, name: String) {
        self.coordinate = coordinate
        self.title = name
        self.subtitle = "TODO"
        super.init()
    }
}

extension MKRouteStep {
    /// Returns a CLLocation (with lat/long) for an MKRouteStep
    func getLocation() -> CLLocation {
        return CLLocation(latitude: polyline.coordinate.latitude, longitude: polyline.coordinate.longitude)
    }
}

// Optional directions to checkpoints using small sphere nodes only visible using the camera.
extension ARCameraViewController {
    
    /// Loads all the steps from a DirectionRequest that will help navigate the user to each checkpoint
    func getNavigationSteps(to checkpoint: MKPointAnnotation) {
        // Firstly empty any previously stored directions
        clearDirections()
        
        let group = DispatchGroup()
        group.enter()
        
        DispatchQueue.global(qos: .default).async {
            let destLocation = checkpoint.coordinate
            
            NavigationService.getDirections(destinationLocation: destLocation, request: MKDirectionsRequest()) { steps in
                for step in steps {
                    self.directionAnnontations.append(DirectionStep(coordinate: step.getLocation().coordinate, name: step.instructions))
                }
                self.steps.append(contentsOf: steps)
                group.leave()
            }
            
            // All steps must be added before moving on
            group.wait()
            
            self.getLocationData()
        }
    }
    
    /// Populates the arrays and adds data to the relevant views (namely MapView and ARView)
    func getLocationData() {
        for (index, step) in steps.enumerated() {
            setTripLegFromStep(step, and: index)
        }
        for leg in currentTripLegs {
            update(intermediary: leg)
        }
        
        // Add circles:
        // as step points to the map view
        addMapAnnotations()
        // and anchors to the ARView
        addAnchors(steps: steps)
    }
    
    /// Determines whether leg is first leg or not and routes logic accordingly
    private func setTripLegFromStep(_ tripStep: MKRouteStep, and index: Int) {
        if index > 0 {
            getTripLeg(for: index, and: tripStep)
        } else {
            getInitialLeg(for: tripStep)
        }
    }
    
    /// Calculates intermediary coordinates for route step that is not first
    private func getTripLeg(for index: Int, and tripStep: MKRouteStep) {
        let previousIndex = index - 1
        let previousStep = steps[previousIndex]
        let previousLocation = CLLocation(latitude: previousStep.polyline.coordinate.latitude, longitude: previousStep.polyline.coordinate.longitude)
        let nextLocation = CLLocation(latitude: tripStep.polyline.coordinate.latitude, longitude: tripStep.polyline.coordinate.longitude)
        let intermediarySteps = CLLocationCoordinate2D.getIntermediaryLocations(currentLocation: previousLocation, destinationLocation: nextLocation)
        currentTripLegs.append(intermediarySteps)
    }
    
    /// Calculates intermediary coordinates for first route step
    private func getInitialLeg(for tripStep: MKRouteStep) {
        guard let userLocation = locationManager.location else { return }
        
        let nextLocation = CLLocation(latitude: tripStep.polyline.coordinate.latitude, longitude: tripStep.polyline.coordinate.longitude)
        let intermediaries = CLLocationCoordinate2D.getIntermediaryLocations(currentLocation: userLocation, destinationLocation: nextLocation)
        currentTripLegs.append(intermediaries)
    }
    
    /// Adds calculated distances to annotations and locations arrays
    private func update(intermediary locations: [CLLocationCoordinate2D]) {
        for intermediaryLocation in locations {
            self.directionAnnontations.append(DirectionStep(coordinate: intermediaryLocation, name: String(describing:intermediaryLocation)))
            self.locations.append(CLLocation(latitude: intermediaryLocation.latitude, longitude: intermediaryLocation.longitude))
        }
    }
    
    /// Adds small circles as a navigation guide on the mapview
    private func addMapAnnotations() {
        directionAnnontations.forEach { annotation in
            DispatchQueue.main.async {
                self.mapView.add(MKCircle(center: annotation.coordinate, radius: 0.2))
            }
        }
    }
}


struct NavigationService {
    /// Returns the steps of a route (found using a direction request) to a specified location.
    static func getDirections(destinationLocation: CLLocationCoordinate2D, request: MKDirectionsRequest, completion: @escaping ([MKRouteStep]) -> Void) {
        var steps: [MKRouteStep] = []
        
        let placeMark = MKPlacemark(coordinate: destinationLocation)
        
        request.destination = MKMapItem(placemark: placeMark)
        request.source = MKMapItem.forCurrentLocation()
        // TODO: Explore alternative routes?
        request.requestsAlternateRoutes = false
        request.transportType = .walking
        
        let directions = MKDirections(request: request)
        
        directions.calculate { response, error in
            if error != nil {
                print("Error getting directions")
            } else {
                guard let response = response else { return }
                for route in response.routes {
                    steps.append(contentsOf: route.steps)
                }
                completion(steps)
            }
        }
    }
}
