//
//  ScrollViewController.swift
//  FitnessApp
//
//  Created by Josh Cotterell on 17/02/2018.
//  Copyright © 2018 Josh Cotterell. All rights reserved.
//

import UIKit
import FirebaseAuth

class ScrollViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    let views = [LoginView(), RegisterView()]
    
    let pageControl: UIPageControl =  {
        let pc = UIPageControl()
        pc.numberOfPages = 2
        return pc
    }()
    
    let showLoginBtn: UIButton = {
        let loginBtn = UIButton()
        loginBtn.setTitle("Login", for: .normal)
        loginBtn.setTitleColor(.white, for: .normal)
        loginBtn.addTarget(self, action: #selector(showLoginView), for: .touchUpInside)
        return loginBtn
    }()
    
    let showRegisterBtn: UIButton = {
        let registerBtn = UIButton()
        registerBtn.setTitle("Register", for: .normal)
        registerBtn.setTitleColor(.white, for: .normal)
        registerBtn.addTarget(self, action: #selector(showRegisterView), for: .touchUpInside)
        return registerBtn
    }()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if user != nil {
                 // User successfully signed in
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.statusBarStyle = .lightContent
        self.setNeedsStatusBarAppearanceUpdate()
        
        collectionView?.backgroundColor = .darkBackground
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        collectionView?.addGestureRecognizer(tapGesture)
        
        collectionView?.alwaysBounceHorizontal = false
        collectionView?.isPagingEnabled = true
        collectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        
        let stackView = UIStackView()
        stackView.addArrangedSubview(showLoginBtn)
        stackView.addArrangedSubview(pageControl)
        stackView.addArrangedSubview(showRegisterBtn)
        
        showLoginBtn.anchor(stackView.topAnchor, bottom: stackView.bottomAnchor, left: stackView.leftAnchor, right: nil, topConstant: 0, bottomConstant: 0, leftConstant: 0, rightConstant: 0, width: 100, height: 0)
        showRegisterBtn.anchor(stackView.topAnchor, bottom: stackView.bottomAnchor, left: nil, right: stackView.rightAnchor, topConstant: 0, bottomConstant: 0, leftConstant: 0, rightConstant: 0, width: 100, height: 0)
        pageControl.anchor(stackView.topAnchor, bottom: stackView.bottomAnchor, left: showLoginBtn.rightAnchor, right: showRegisterBtn.leftAnchor, topConstant: 0, bottomConstant: 0, leftConstant: 0, rightConstant: 0, width: 0, height: 0)
        
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.spacing = 5
        
        view.addSubview(stackView)
        stackView.anchor(nil, bottom: view.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 0, bottomConstant: -15, leftConstant: 0, rightConstant: 0, width: 0, height: 40)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Login and Register views
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.backgroundColor = .darkBackground
        
        let view = views[indexPath.row]
        cell.addSubview(view)
        view.anchorCenterSuperview(withWidth: cell.frame.width, withHeight: cell.frame.height)
        
        return cell
    }
    
    @objc func showLoginView() {
        // scroll to other view
        let indexPath = IndexPath(item: 0, section: 0)
        pageControl.currentPage = 0
        collectionView?.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    @objc func showRegisterView() {
        // scroll to other view
        let indexPath = IndexPath(item: 1, section: 0)
        pageControl.currentPage = 1
        collectionView?.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let x = targetContentOffset.pointee.x
        
        pageControl.currentPage = Int(x/view.frame.width)
    }
    
}
