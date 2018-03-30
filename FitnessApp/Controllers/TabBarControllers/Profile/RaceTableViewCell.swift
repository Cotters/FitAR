//
//  RaceTableViewCell.swift
//  FitnessApp
//
//  Created by Josh Cotterell on 28/02/2018.
//  Copyright © 2018 Josh Cotterell. All rights reserved.
//

import UIKit

class RaceTableViewCell: UITableViewCell {
    
    let nameLbl: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.boldSystemFont(ofSize: 22)
        lbl.textColor = .black
        return lbl
    }()
    
    let distanceLbl: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 16)
        lbl.textColor = .lightGray
        return lbl
    }()
    
    let ratingLbl: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .left
        lbl.font = UIFont.boldSystemFont(ofSize: 16)
        return lbl
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .white
        
        // Add to all labels to the view
        contentView.addSubview(nameLbl)
        contentView.addSubview(ratingLbl)
        contentView.addSubview(distanceLbl)
        
        // Anchor title
        nameLbl.anchor(contentView.topAnchor, bottom: nil, left: contentView.leftAnchor, right: nil, topConstant: 10, bottomConstant: -10, leftConstant: 10, rightConstant: 0, width: 0, height: 25)
        // Anchor distance lbl
        distanceLbl.anchor(nameLbl.topAnchor, bottom: nil, left: nameLbl.rightAnchor, right: contentView.rightAnchor, topConstant: 0, bottomConstant: 0, leftConstant: 0, rightConstant: -10, width: 0, height: 25)
        // Anchor rating lbl
        ratingLbl.anchor(nameLbl.bottomAnchor, bottom: nil, left: nameLbl.leftAnchor, right: distanceLbl.rightAnchor, topConstant: 0, bottomConstant: 0, leftConstant: 0, rightConstant: 0, width: 0, height: 25)
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func addRaceDetails(_ race: Race) {
        // Retrieve details
        let distance = race.distance
        let rating = race.rating
        
        self.nameLbl.text = race.name
        self.distanceLbl.text = "\(Int(distance)) meters"
        var starRating = "Rating: "
        if rating < 1 {
            starRating += "👎"
        } else {
            // Display rating as a star rating
            for _ in 1...Int(rating) {
                starRating += "⭐️"
            }
        }
        self.ratingLbl.text = starRating
    }
    
    
    
}
