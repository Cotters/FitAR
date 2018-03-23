//
//  FriendProfileViewController.swift
//  FitnessApp
//
//  Created by Josh Cotterell on 11/03/2018.
//  Copyright © 2018 Josh Cotterell. All rights reserved.
//

import UIKit

protocol ChallengeUserDelegate {
    func storeChallenge(_ race: Race)
}

class FriendProfileViewController: UIViewController, ChallengeUserDelegate {
    
    let profileImageView: UIImageView = {
        let imgView = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        imgView.image = #imageLiteral(resourceName: "profile_placeholder")
        imgView.clipsToBounds = true
        imgView.contentMode = .scaleAspectFit
        imgView.layer.cornerRadius = imgView.frame.width/2
        return imgView
    }()
    
    let challengeButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Challenge", for: .normal)
        btn.backgroundColor = .black
        btn.setTitleColor(.white, for: .normal)
        btn.addTarget(self, action: #selector(challengeFriend), for: .touchUpInside)
        return btn
    }()
    
    var friend: Profile!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        navigationItem.title = friend.getName()
        
        let guide = view.safeAreaLayoutGuide
        view.addSubview(profileImageView)
        profileImageView.anchor(guide.topAnchor, bottom: nil, left: nil, right: nil, topConstant: 20, bottomConstant: 0, leftConstant: 0, rightConstant: 0, width: 100, height: 100)
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        view.addSubview(challengeButton)
        challengeButton.anchor(nil, bottom: view.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 0, bottomConstant: -10, leftConstant: 5, rightConstant: -5, width: 0, height: 40)
    }
    
    @objc func challengeFriend() {
        let raceCreationView = RaceCreationController()
        raceCreationView.raceType = .challenge
        raceCreationView.delegate = self
        navigationController?.pushViewController(raceCreationView, animated: true)
    }
    
    func storeChallenge(_ race: Race) {
        // Stores the race in the friend's database profile
        let friendId = friend.getId()
        let raceService = RaceService()
        raceService.store(race: race, forUserWithId: friendId)
        // TODO: Breaks the app - probs due to using ! on nil optionals
    }
}
