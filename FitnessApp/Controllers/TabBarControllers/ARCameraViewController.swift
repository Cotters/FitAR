//
//  ViewController.swift
//  FitnessApp
//
//  Created by Josh Cotterell on 24/11/2017.
//  Copyright © 2017 Josh Cotterell. All rights reserved.
//

import UIKit
import ARKit
import SceneKit
import CoreLocation
import MapKit

/* TODO **
 
 * Change size of the pin so it's really big from a distance - (no scale?)        [In Progress]
 * Add the pin from the destination race directly to the view.                    [DONE]
 
 */

class ARCameraViewController: GameMapViewController, ARSCNViewDelegate {
    
    private var sceneView = ARSCNView()
    private var configuration = ARWorldTrackingConfiguration()
    
    let pinNode = SCNNode()
    var anchors: [ARAnchor] = []
    
    let progressBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("Cheat", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.backgroundColor = .green
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        btn.addTarget(self, action: #selector(nextCheckpoint), for: .touchUpInside)
        return btn
    }()
    
    var nodes: [SCNNode] = []
    
    /// Enable whether the user can see how to get to the checkpoint using small nodes visible only on the camera
    private var showDirections = true
    
    /// Stores all the direction points
    var directionAnnontations: [DirectionStep] = []
    var steps: [MKRouteStep] = []
    var currentTripLegs: [[CLLocationCoordinate2D]] = []
    var locations: [CLLocation] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Scene View
        view.addSubview(sceneView)
        sceneView.anchor(view.topAnchor, bottom: nil, left: view.leftAnchor, right: view.rightAnchor, topConstant: 0, bottomConstant: 0, leftConstant: 0, rightConstant: 0, width: 0, height: view.frame.height*0.6)
        
        // Add relevant items to the view
        addMapView(topAnchor: sceneView.bottomAnchor, bottom: view.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, width: 0, height: 0)
        addRaceSelectBtn()
        
        // Reset Button
        addRaceResetBtn()
        
        // TODO: Remove - only for testing
        // Progess Button
        view.addSubview(progressBtn)
        progressBtn.anchor(mapView.topAnchor, bottom: nil, left: view.leftAnchor, right: nil, topConstant: 5, bottomConstant: 0, leftConstant: 5, rightConstant: 0, width: 80, height: 20)
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = false
        
        // Create a new empty scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        
        /*
         Prevent the screen from being dimmed after a while as users will likely
         have long periods of interaction without touching the screen or buttons.
         */
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func addDirections(from start: MKPointAnnotation, to destination: MKPointAnnotation) {
        // Remove all current scene nodes
        removeSCNNodes()
        
        // If the user wants visible directions, this will load them
        if showDirections {
            // Retrieves steps to current checkpoint and adds them to the map
            self.getNavigationSteps(to: destination)
        }
        
        // Show destination on map
        //TODO: Remove this for actual game and add forfeit btn
        // - although the accuracy of AR nodes might make it difficult
        mapView.addAnnotation(destination)
        
        // TODO: Check altitude of pin - could put it 20-50m higher?
        // Add a pin over the checkpoint; only visible using camera
        let destLoc = CLLocation(coordinate: destination.coordinate, altitude: start.getLocation().altitude, horizontalAccuracy: kCLLocationAccuracyBest , verticalAccuracy: kCLLocationAccuracyBest, timestamp: start.getLocation().timestamp)
        self.addPin(at: destLoc, withTitle: destination.title!)
    }
    
    /// For intermediary steps - creates a trail from user to the next checkpoint
    private func addSphere(for location: CLLocation) {
        guard let userLocation = locationManager.location else { return }
        let origin = CLLocation(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        let locationTransform = MatrixHelper.transformMatrix(for: matrix_identity_float4x4, originLocation: origin, location: location)
        let stepAnchor = ARAnchor(transform: locationTransform)
        let lowerLoc = CLLocation(coordinate: location.coordinate, altitude: location.altitude-5, horizontalAccuracy: kCLLocationAccuracyBest , verticalAccuracy: kCLLocationAccuracyBest, timestamp: location.timestamp)
        let sphere = BaseNode(title: "", location: lowerLoc)
        sphere.addSphere(with: 0.25, and: .systemBlue)
        anchors.append(stepAnchor)
        sceneView.session.add(anchor: stepAnchor)
        sceneView.scene.rootNode.addChildNode(sphere)
        sphere.anchor = stepAnchor
        nodes.append(sphere)
    }
    
    /// Adds a giant pin over each checkpoint
    private func addPin(at location: CLLocation, withTitle title: String) {
        guard let userLocation = locationManager.location else { return }
        let origin = CLLocation(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        let locationTransform = MatrixHelper.transformMatrix(for: matrix_identity_float4x4, originLocation: origin, location: location)
        let stepAnchor = ARAnchor(transform: locationTransform)
        let node = BaseNode(title: title, location: location)
        
        let distance = location.distance(from: origin)
        node.addPin(withDistance: distance)
        anchors.append(stepAnchor)
        node.location = location
        node.anchor = stepAnchor
        node.eulerAngles.x = -.pi/2
        sceneView.session.add(anchor: stepAnchor)
        sceneView.scene.rootNode.addChildNode(node)
        nodes.append(node)
        
        
        
        // TODO: Could be the place to check whether to add the pin?
        // Problem is that the pin may be so far away that a heading 2º out of line would be
        // really inacurate on the camera.
        // Scale relevant to distance, unless they are say 3000m away, then:
        // distance from node to user * some constant
        if distance > 100 {
            let scale = 100 / Float(distance)
            print(scale)
            let adjustedDistance = distance * Double(scale)
            // ^ Will always be 100 because (distance * 100 / distance) = 100
            
            // Translate closer
            let locationTranslation = origin.translation(toLocation: node.location)
            
            let adjustedTranslation = SCNVector3(
                x: Float(locationTranslation.longitudeTranslation) * scale,
                y: Float(locationTranslation.altitudeTranslation) * scale,
                z: Float(locationTranslation.latitudeTranslation) * scale)
            
            guard let pointOfView = self.sceneView.pointOfView else {
                print("oops")
                return
            }
            
            let currentPosition = sceneView.scene.rootNode.convertPosition(pointOfView.position, to: sceneView.scene.rootNode)

            let position = SCNVector3(
                x: currentPosition.x + adjustedTranslation.x,
                y: currentPosition.y + adjustedTranslation.y,
                z: currentPosition.z - adjustedTranslation.z)

            // Brings it closer and to an appropriate scale
            node.position = position
            node.scale = SCNVector3(x: 1, y: 1, z: 1)

        } else {
            print("not scaling")
            node.scale = SCNVector3(1, 1, 1)
        }
    }
    
    func addAnchors(steps: [MKRouteStep]) {
        for location in locations { addSphere(for: location) }
    }
    
    override func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for region in manager.monitoredRegions {
            if let cRegion = region as? CLCircularRegion {
                if cRegion.contains(manager.location!.coordinate) && race != nil {
                    // Finished race
                    showMessage(withTitle: "Woohoo!", message: "You have arrived at a checkpoint.")
                    nextCheckpoint()
                }
            }
        }
    }
    
    func make2dNode(image: UIImage, width: CGFloat = 0.1, height: CGFloat = 0.1) -> SCNNode {
        let plane = SCNPlane(width: width, height: height)
        plane.firstMaterial!.diffuse.contents = image
        let node = SCNNode(geometry: plane)
        node.constraints = [SCNBillboardConstraint()]
        return node
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Use compass heading to point -Z axis north
        configuration.worldAlignment = .gravityAndHeading

        // Run the view's session
        sceneView.session.run(configuration)
        sceneView.delegate = self
        
    }
    
    func checkCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) -> Void in
            if !granted {
                // Link to settings to allow user to change their camera usage setting
                let settingsURL = URL(string: UIApplicationOpenSettingsURLString)
                self.showSettingsAlert(withMessage: "You must enable camera usage permission.", and: settingsURL)
                return
            }
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        let pin = make2dNode(image: UIImage(named: "pin")!)
        // TODO: Scale pin to be larger
        node.addChildNode(pin)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - ARSCNViewDelegate
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        print("Session failed. Changing worldAlignment property.")
        print(error.localizedDescription)
        
         // Sometimes getting a bug from worldAlignment being .gravityAndHeading - handled using:
         if let arError = error as? ARError {
             switch arError.errorCode {
             case 102:
                // Sensor failed - worldAlignment bug
                configuration.worldAlignment = .gravity
                restartSessionWithoutDelete()
             case 103:
                // Camera not authorised error
                checkCameraPermission()
             default:
                showMessage(withTitle: "Error", message: "\(error.localizedDescription)")
                restartSessionWithoutDelete()
            }
         }
    }
    
    func removeSCNNodes() {
        // Remove nodes from view
        sceneView.session.pause()
        
        sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
            node.removeFromParentNode()
        }
        sceneView.session.run(configuration, options: [.removeExistingAnchors])
    }
    
    func clearDirections() {
        directionAnnontations.removeAll()
        locations.removeAll()
        currentTripLegs.removeAll()
        steps.removeAll()
    }
    
    func restartSessionWithoutDelete() {
        // Refresh the camera view by removing everything
        sceneView.session.pause()
        
        // Remove nodes and anchors
        removeSCNNodes()
        sceneView.session.run(configuration, options: [
            .resetTracking,
            .removeExistingAnchors])
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        showMessage(withTitle: "Error", message: "Session was interupted.")
    }
    
    @objc override func resetScene() {
        // Reset variables
        race = nil
        clearDirections()
        currentCheckpointCount = 0
        // Remove everything from mapView
        mapView.clear()
        // Remove all nodes from scene
        restartSessionWithoutDelete()
        // Toggle buttons
        toggleRaceResetBtn(show: false)
        toggleRaceSelectBtn(show: true)
    }
}

// Turns strings into images to be displayed on the camera view
extension String {
    func image() -> UIImage? {
        let size = CGSize(width: 30, height: 35)
        UIGraphicsBeginImageContextWithOptions(size, false, 0);
        UIColor.clear.set()
        let rect = CGRect(origin: CGPoint(), size: size)
        UIRectFill(CGRect(origin: CGPoint(), size: size))
        (self as NSString).draw(in: rect, withAttributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 30)])
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
