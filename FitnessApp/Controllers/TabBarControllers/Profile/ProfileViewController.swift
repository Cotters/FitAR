//
//  ProfileViewController.swift
//  FitnessApp
//
//  Created by Josh Cotterell on 24/11/2017.
//  Copyright © 2017 Josh Cotterell. All rights reserved.
//

import UIKit
import FirebaseAuth

class ProfileViewController: UserContainedViewController, SelectRaceDelegate {
    
    let profileImageView: UIImageView = {
        let imgView = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        imgView.image = #imageLiteral(resourceName: "profile_placeholder")
        imgView.clipsToBounds = true
        imgView.contentMode = .scaleAspectFit
        imgView.layer.cornerRadius = imgView.frame.width/2
        return imgView
    }()
    
    let createRaceBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("Create Race", for: .normal)
        btn.backgroundColor = .systemBlue
        btn.tintColor = .white
        btn.addTarget(self, action: #selector(showRaceCreator), for: .touchUpInside)
        return btn
    }()
    
    let showRacesBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("Show My Races", for: .normal)
        btn.backgroundColor = .systemBlue
        btn.tintColor = .white
        btn.addTarget(self, action: #selector(showUserRaces), for: .touchUpInside)
        return btn
    }()
    
    let showFriendsBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("Friends", for: .normal)
        btn.backgroundColor = .systemBlue
        btn.tintColor = .white
        btn.addTarget(self, action: #selector(showFriendsList), for: .touchUpInside)
        return btn
    }()
    
    let showChallengesBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("Show Challenges", for: .normal)
        btn.backgroundColor = .systemBlue
        btn.tintColor = .white
        btn.addTarget(self, action: #selector(showChallenges), for: .touchUpInside)
        return btn
    }()
    
    let logoutBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("Logout", for: .normal)
        btn.backgroundColor = .darkSystemBlue
        btn.tintColor = .white
        btn.addTarget(self, action: #selector(logout), for: .touchUpInside)
        return btn
    }()
    
    var selectedRace: Race! {
        didSet {
            print("Race selected")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationItem.title = self.profile.getName()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup view
        view.backgroundColor = .white
        navigationItem.title = self.profile.getName()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        
        // Profile image
        view.addSubview(profileImageView)
        let guide = view.safeAreaLayoutGuide
        profileImageView.anchor(guide.topAnchor, bottom: nil, left: nil, right: nil, topConstant: 20, bottomConstant: 0, leftConstant: 0, rightConstant: 0, width: 100, height: 100)
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        // Buttons (in a stack view)
        let stackView = UIStackView()
        stackView.addArrangedSubview(createRaceBtn)
        stackView.addArrangedSubview(showRacesBtn)
        stackView.addArrangedSubview(showFriendsBtn)
        stackView.addArrangedSubview(showChallengesBtn)
        stackView.addArrangedSubview(logoutBtn)
        
        createRaceBtn.heightAnchor.constraint(equalToConstant: 50).isActive = true
        showRacesBtn.heightAnchor.constraint(equalToConstant: 50).isActive = true
        showFriendsBtn.heightAnchor.constraint(equalToConstant: 50).isActive = true
        showChallengesBtn.heightAnchor.constraint(equalToConstant: 50).isActive = true
        logoutBtn.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 5
        
        view.addSubview(stackView)
        stackView.anchor(nil, bottom: guide.bottomAnchor, left: guide.leftAnchor, right: guide.rightAnchor, topConstant: 0, bottomConstant: -10, leftConstant: 10, rightConstant: -10, width: 0, height: 0)
        
    }
    
    // MARK: Navigation between views + logout
    @objc func showRaceCreator() {
        let raceCreationView = RaceCreationController()
        
        // Get the race type: Checkpoint, Destination etc.
        let actions = [
            UIAlertAction(title: "Checkpoint", style: .default, handler: {_ in
                raceCreationView.raceType = .checkpoint
                self.navigationController?.pushViewController(raceCreationView, animated: true)
            }),
            UIAlertAction(title: "POI", style: .default, handler: {_ in
                raceCreationView.raceType = .poi
                self.navigationController?.pushViewController(raceCreationView, animated: true)
        })]
        showAlert(withTitle: "Race Type", message: "What type of race do you wish to create?", actions: actions, style: .actionSheet)
    }
    
    @objc func showUserRaces() {
        // show tableview with races
        let racePickerView = EditRacesTableViewController() //RacePickerViewController()
//        racePickerView.raceType = .checkpoint //TODO:  Fetch all races by user
        navigationController?.pushViewController(racePickerView, animated: true)
    }
    
    @objc func showFriendsList() {
        let friendsTableView = FriendsTableViewController()
        navigationController?.pushViewController(friendsTableView, animated: true)
    }
    
    func didSelectRace(_ race: Race) {
        selectedRace = race
    }
    
    @objc func showChallenges() {
        let challengesTableView = ChallengesTableViewController()
        self.navigationController?.pushViewController(challengesTableView, animated: true)
    }
    
    @objc func logout() {
        let firebaseAuth = Auth.auth()
    
        do {
            try firebaseAuth.signOut()
            self.navigationController?.presentLoginScreen()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    
    }
    
    
}
