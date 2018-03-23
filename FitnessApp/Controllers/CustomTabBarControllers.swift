//
//  CustomTabBarControllers.swift
//  FitnessApp
//
//  Created by Josh Cotterell on 24/11/2017.
//  Copyright © 2017 Josh Cotterell. All rights reserved.
//

import UIKit
import FirebaseAuth

/// The main navigation for the app. Contains all of the main independent views
/// outlined by the desgin and requirements.
class CustomTabBarControllers: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let homeController = UINavigationController(rootViewController: HomeViewController())
        homeController.navigationItem.title = "Home"
        homeController.tabBarItem = UITabBarItem(tabBarSystemItem: .history, tag: 1)
        homeController.tabBarItem.title = "Home"
        
        
        let mapController = MapController()
        mapController.tabBarItem.image = #imageLiteral(resourceName: "location-xs")
        mapController.tabBarItem.title = "Maps"
        
        
        let cameraController = ARCameraViewController()
        cameraController.tabBarItem.image = #imageLiteral(resourceName: "camera_icon")
        cameraController.tabBarItem.title = "AR View"
        
        
        let profileController = UINavigationController(rootViewController: ProfileViewController())
        profileController.tabBarItem.image = #imageLiteral(resourceName: "profile_icon")
        profileController.title = "Profile"
        
        // Stores all the root views within the tabBar
        viewControllers = [homeController, mapController, cameraController, profileController]
        
        // Add a small border to the top of the tab bar
        let topBorder = CALayer()
        topBorder.frame = CGRect(x: 0, y: 0, width: 1000, height: 0.5)
        topBorder.backgroundColor = UIColor(r: 201, g: 203, b: 207).cgColor
        
        tabBar.isTranslucent = false
        tabBar.clipsToBounds = true
        tabBar.tintColor = .systemBlue
        tabBar.layer.addSublayer(topBorder)
        
    }
    
}
