//
//  HomeViewController.swift
//  FitnessApp
//
//  Created by Josh Cotterell on 24/11/2017.
//  Copyright © 2017 Josh Cotterell. All rights reserved.
//

import UIKit
import CoreMotion
import CoreLocation
import HealthKit
import FirebaseAuth

class HomeViewController: UserContainedViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, CLLocationManagerDelegate {
    
    var collectionView: UICollectionView!
    
    let pedometer = CMPedometer()
    
    var stepsArray: [Int] = [0,0]
    
    var midnightToday: Date!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "Home"
        
        
        // CollectionView Setup
        let flowLayout = UICollectionViewFlowLayout()
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        collectionView.register(HomeViewCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        self.view.addSubview(collectionView)
        
        var cal = Calendar.current
        var comps = cal.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date())
        comps.hour = 0
        comps.minute = 0
        comps.second = 0
        let timeZone = NSTimeZone.system
        cal.timeZone = timeZone
        midnightToday = cal.date(from: comps)!

        startStepUpdates()
        
    }
    
    func startStepUpdates() {
        if CMPedometer.isStepCountingAvailable() {
            // Daily step count
            self.pedometer.startUpdates(from: midnightToday, withHandler: { (data, error) in
                DispatchQueue.main.async {
                    if error != nil {
                        print(error!)
                        return
                    }
                    guard let data = data else { return }
                    self.stepsArray[0] = data.numberOfSteps as! Int
                    self.collectionView.reloadData()
                }
            })
            
            // Weekly step count
            let fromDate = Date(timeIntervalSinceNow: -86400 * 7)
            self.pedometer.queryPedometerData(from: fromDate, to: Date(), withHandler: { (data, error) in
                DispatchQueue.main.async {
                    if error != nil {
                        print(error!)
                        return
                    }
                    guard let data = data else { return }
                    self.stepsArray[1] = data.numberOfSteps as! Int
                    self.collectionView.reloadData()
                }
            })
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stepsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath as IndexPath) as! HomeViewCell
        
        let steps = stepsArray[indexPath.row]
        cell.cellLabel.text = "\(steps)"
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 50.0
        let collectionViewSize = collectionView.frame.size.width - padding
        
        return CGSize(width: collectionViewSize/2, height: collectionViewSize/2)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    }
    
}

class HomeViewCell: UICollectionViewCell {
    
    let cellLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.backgroundColor = .clear
        lbl.textColor = .white
        lbl.textAlignment = .center
        lbl.text = "Loading..."
        lbl.font = UIFont.boldSystemFont(ofSize: 22)
        return lbl
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentView.backgroundColor = .systemBlue
        
        contentView.addSubview(cellLabel)
        cellLabel.anchorCenterSuperview(withWidth: self.frame.size.width, withHeight: self.frame.size.height)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}

