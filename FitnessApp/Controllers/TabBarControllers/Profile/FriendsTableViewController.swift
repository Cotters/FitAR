//
//  FriendsTableViewController.swift
//  FitnessApp
//
//  Created by Josh Cotterell on 09/03/2018.
//  Copyright © 2018 Josh Cotterell. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class FriendsTableViewController: CustomTableViewController {
    
    var friends: [Profile] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Add tableview and spinner
        setupView()
        
        // NavItem settings
        navigationItem.title = "Friends"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addFriend))
        
        // Retrieve friends from database
        loadFriends()
    }
    
    func loadFriends() {
        let ref = Database.database().reference()
        
        // Keeps tracks of the number of pending blocks
        let group = DispatchGroup()
        
        ref.child("users/\(user.uid)/friends").observe(.value) { (snapshot) in
            if !snapshot.exists() {
                return
            }
            let friends = snapshot.value as! NSDictionary
            
            for friend in friends {
                group.enter()
                ref.child("users/\(friend.key)").observe(.value, with: { (snapshot) in
                    let userDict = snapshot.value as! NSDictionary
                    
                    // Get userId and name
                    let id = String(describing: friend.key)
                    let name = userDict["name"] as! String
                    
                    // Store a profile in friends array
                    let profile = Profile(name: name, id: id)
                    self.friends.append(profile)
                    group.leave()
                })
            }
            group.notify(queue: .main, execute: {
                // Once all calls are complete reload tableView data
                self.refreshView()
            })
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendCell", for: indexPath) as! FriendTableViewCell
        
        let friend = friends[indexPath.row]
        cell.nameLabel.text = friend.getName()
        cell.accessoryType = .detailButton
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Show friend's profile
        let friendProfileView = FriendProfileViewController()
        friendProfileView.friend = friends[indexPath.row]
        self.navigationController?.pushViewController(friendProfileView, animated: true)
    }
    
    @objc func addFriend() {
        let alert = UIAlertController(title: "Add friend", message: "Enter your friend's username", preferredStyle: .alert)
        alert.addTextField { (textfield) in
            textfield.placeholder = "Username"
            textfield.autocapitalizationType = UITextAutocapitalizationType.sentences
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { (action) in
            guard let tf = alert.textFields?.first else { return }
            print(tf.text)
        }))
        // Ask for friends name
        present(alert, animated: true, completion: nil)
        
        // TODO: Search DB and add friend under user's friends list
    }
    
}

class FriendTableViewCell: UITableViewCell {
    
    let profileImageView: UIImageView = {
        let imgView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        imgView.image = #imageLiteral(resourceName: "profile_placeholder")
        imgView.clipsToBounds = true
        imgView.contentMode = .scaleAspectFit
        imgView.layer.cornerRadius = 25
        return imgView
    }()
    
    let nameLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.boldSystemFont(ofSize: 18)
        return lbl
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = .white
        
        contentView.addSubview(profileImageView)
        contentView.addSubview(nameLabel)
        
        profileImageView.anchor(contentView.topAnchor, bottom: contentView.bottomAnchor, left: contentView.leftAnchor, right: nil, topConstant: 10, bottomConstant: -10, leftConstant: 10, rightConstant: -10, width: 50, height: 0)
        
        nameLabel.anchor(profileImageView.topAnchor, bottom: profileImageView.bottomAnchor, left: profileImageView.rightAnchor, right: contentView.rightAnchor, topConstant: 0, bottomConstant: 0, leftConstant: 5, rightConstant: 0, width: 0, height: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
