//
//  CustomTableViewController.swift
//  FitnessApp
//
//  Created by Josh Cotterell on 22/03/2018.
//  Copyright © 2018 Josh Cotterell. All rights reserved.
//

import UIKit

/// Custom TableViewController with activity spinner.
/// Designed to be implemented by any table view used in the app.
class CustomTableViewController: UserContainedViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - View Properties
    let activitySpinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.activityIndicatorViewStyle = .gray
        spinner.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        spinner.startAnimating()
        return spinner
    }()
    
    var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    func setupView() {
        view.backgroundColor = .white
        
        // Initialise tableView
        tableView = UITableView(frame: view.bounds, style: .plain)
        // Register different custom cells
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.register(RaceTableViewCell.self, forCellReuseIdentifier: "RaceCell")
        tableView.register(FriendTableViewCell.self, forCellReuseIdentifier: "FriendCell")
        tableView.delegate = self
        tableView.dataSource = self
        
        // Add tableview and format
        let guide = view.safeAreaLayoutGuide
        view.addSubview(tableView)
        tableView.anchor(guide.topAnchor, bottom: guide.bottomAnchor, left: guide.leftAnchor, right: guide.rightAnchor, topConstant: 0, bottomConstant: 0, leftConstant: 0, rightConstant: 0, width: 0, height: 0)
        tableView.backgroundColor = .white
        
        // Add a loading view to the screen while the races are being fetched
        view.addSubview(activitySpinner)
        activitySpinner.anchorCenterSuperview(withWidth: 30, withHeight: 30)
        self.tableView.separatorStyle = .none
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    }
    
    @objc func refreshView() {
        self.activitySpinner.removeFromSuperview()
        self.tableView.separatorStyle = .singleLine
        self.tableView.reloadData()
    }
}
