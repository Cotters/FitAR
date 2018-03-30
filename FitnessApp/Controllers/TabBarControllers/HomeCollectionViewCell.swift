//
//  UserContainedViewController.swift
//  FitnessApp
//
//  Created by Bridget Carroll on 30/03/2018.
//  Copyright © 2018 Josh Cotterell. All rights reserved.
//

import UIKit

class HomeCollectionViewCell: UICollectionViewCell {
    
    let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.backgroundColor = .white
        return iv
    }()
    
    let cellLabel: UILabel = {
        let lbl = UILabel()
        lbl.backgroundColor = .clear
        lbl.textColor = .black
        lbl.textAlignment = .center
        lbl.numberOfLines = 2
        lbl.text = "Loading..."
        lbl.font = UIFont.boldSystemFont(ofSize: 16)
        return lbl
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = .green
        
        contentView.addSubview(iconImageView)
        iconImageView.anchor(contentView.topAnchor, bottom: nil, left: nil, right: nil, topConstant: 10, bottomConstant: 0, leftConstant: 0, rightConstant: 0, width: 60, height: 60)
        iconImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        
        contentView.addSubview(cellLabel)
        cellLabel.anchor(iconImageView.bottomAnchor, bottom: nil, left: contentView.leftAnchor, right: contentView.rightAnchor, topConstant: 10, bottomConstant: 0, leftConstant: 0, rightConstant: 0, width: 0, height: 40)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
