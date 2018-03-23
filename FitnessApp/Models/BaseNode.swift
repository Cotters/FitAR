//
//  BaseNode.swift
//  FitnessApp
//
//  Created by Josh Cotterell on 04/03/2018.
//  Copyright © 2018 Josh Cotterell. All rights reserved.
//

import SceneKit
import ARKit
import CoreLocation

class BaseNode: SCNNode {
    
    let title: String
    
    var anchor: ARAnchor? {
        didSet {
            guard let transform = anchor?.transform else { return }
            self.position = positionFromTransform(transform)
        }
    }
    
    var location: CLLocation!
    
    init(title: String, location: CLLocation) {
        self.title = title
        super.init()
        let billboardConstraint = SCNBillboardConstraint()
        billboardConstraint.freeAxes = SCNBillboardAxis.Y
        constraints = [billboardConstraint]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Basic sphere graphic
    func createSphereNode(with radius: CGFloat, color: UIColor) -> SCNNode {
        let geometry = SCNSphere(radius: radius)
        geometry.firstMaterial?.diffuse.contents = color
        let sphereNode = SCNNode(geometry: geometry)
        return sphereNode
    }
    
    /// Add a giant pin to be visible across a landscape
    func createPinNode(withDistance distance: CLLocationDistance) -> SCNNode {
        // TODO: Could be the place to check whether to add the pin?
        let pinImage = UIImage(named: "pin")!
        
        let plane = SCNPlane(width: pinImage.size.width / 100, height: pinImage.size.height / 100)
        plane.firstMaterial!.diffuse.contents = pinImage
        plane.firstMaterial!.lightingModel = .constant
        
        // TODO: This is in the init, might not need
        let billboardConstraint = SCNBillboardConstraint()
        billboardConstraint.freeAxes = SCNBillboardAxis.Y
        constraints = [billboardConstraint]
        
        let pin = SCNNode(geometry: plane)
        return pin
    }
    
    // Add graphic as child node - basic
    func addSphere(with radius: CGFloat, and color: UIColor) {
        let sphereNode = createSphereNode(with: radius, color: color)
        addChildNode(sphereNode)
    }
    
    // Add graphic as child node
    func addPin(withDistance distance: CLLocationDistance) {
        // Add giant pin
        let pin = createPinNode(withDistance: distance)
        addChildNode(pin)
        // Add title text
        let titleText = SCNText(string: title, extrusionDepth: 0.5)
        titleText.font = UIFont.boldSystemFont(ofSize: 10)
        titleText.firstMaterial?.diffuse.contents = UIColor.systemBlue
        let titleTxtNode = SCNNode(geometry: titleText)
        addChildNode(titleTxtNode)
    }
    
    // Add graphic as child node - with text
    
    func addNode(with radius: CGFloat, and color: UIColor, and text: String) {
        let sphereNode = createSphereNode(with: radius, color: color)
        let newText = SCNText(string: title, extrusionDepth: 0.05)
        newText.font = UIFont (name: "AvenirNext-Medium", size: 1)
        newText.firstMaterial?.diffuse.contents = UIColor.red
        let _textNode = SCNNode(geometry: newText)
        let annotationNode = SCNNode()
        annotationNode.addChildNode(_textNode)
        annotationNode.position = sphereNode.position
        addChildNode(sphereNode)
        addChildNode(annotationNode)
    }
    
    // Setup
    func positionFromTransform(_ transform: matrix_float4x4) -> SCNVector3 {
        
        //    column 0  column 1  column 2  column 3
        //         1        0         0       X    
        //         0        1         0       Y    
        //         0        0         1       Z    
        //         0        0         0       1    
        
        return SCNVector3Make(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
    }
}

