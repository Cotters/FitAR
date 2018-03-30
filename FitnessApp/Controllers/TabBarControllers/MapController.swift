//
//  MapController.swift
//  FitnessApp
//
//  Created by Josh Cotterell on 29/01/2018.
//  Copyright © 2018 Josh Cotterell. All rights reserved.
//

import UIKit

class MapController: GameMapViewController {
    
    let progressBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("Cheat", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.backgroundColor = .green
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        btn.addTarget(self, action: #selector(nextCheckpoint), for: .touchUpInside)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // View Setup
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        
        // Add relevant items to the view
        addMapView() // Full span
        addRaceSelectBtn()
        addRaceResetBtn()
        addUserLocationBtn()
        
        mapView.addSubview(progressBtn)
        progressBtn.anchor(mapView.topAnchor, bottom: nil, left: mapView.leftAnchor, right: nil, topConstant: 10, bottomConstant: 0, leftConstant: 10, rightConstant: 0, width: 80, height: 20)
        
        
    }
    
}
