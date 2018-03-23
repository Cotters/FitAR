//
//  RegisterViewController.swift
//  FitnessApp
//
//  Created by Josh Cotterell on 17/02/2018.
//  Copyright © 2018 Josh Cotterell. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class RegisterView: UIView {
    
    let nameTextField: UITextField = {
        let tf = UITextField()
        tf.backgroundColor = .white
        tf.placeholder = "Full Name"
        tf.autocapitalizationType = UITextAutocapitalizationType.words
        tf.leftViewMode = .always
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 5))
        return tf
    }()
    
    let emailTextField: UITextField = {
        let tf = UITextField()
        tf.backgroundColor = .white
        tf.placeholder = "email"
        tf.keyboardType = .emailAddress
        tf.leftViewMode = .always
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 5))
        return tf
    }()
    
    let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.layer.borderColor = UIColor.white.cgColor
        tf.backgroundColor = .white
        tf.leftViewMode = .always
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 5))
        tf.placeholder = "Password"
        tf.isSecureTextEntry = true
        return tf
    }()
    
    let registerBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("Register", for: .normal)
        btn.backgroundColor = UIColor(r: 0, g: 255, b: 68)
        btn.setTitleColor(.black, for: .normal)
        btn.addTarget(self, action: #selector(registerUser), for: .touchUpInside)
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let stackView = UIStackView()
        stackView.addArrangedSubview(nameTextField)
        stackView.addArrangedSubview(emailTextField)
        stackView.addArrangedSubview(passwordTextField)
        stackView.addArrangedSubview(registerBtn)
        
        nameTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        emailTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        passwordTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        registerBtn.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.axis = .vertical
        stackView.spacing = 10
        
        addSubview(stackView)
        stackView.anchor(nil, bottom: nil, left: self.leftAnchor, right: self.rightAnchor, topConstant: 0, bottomConstant: 0, leftConstant: 20, rightConstant: -20, width: 0, height: 0)
        stackView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func registerUser() {
        print("Adding user...")
        guard let name = nameTextField.text,
        let email = emailTextField.text,
        let password = passwordTextField.text else { return }
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if error != nil {
                print(error.debugDescription)
                return
            }
            // Add user profile to the database
//            guard let user = user else { return }
            let ref = Database.database().reference()
            // Store the given name in the database
            ref.child("users/\(user!.uid)").setValue(["name" : name])
            
            // Set the display name for this account
            let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
            changeRequest?.displayName = name
            changeRequest?.commitChanges { (error) in
                if error != nil {
                    print(error.debugDescription)
                }
            }
        }
        
    }
    
    
}
