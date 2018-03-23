//
//  LoginView.swift
//  FitnessApp
//
//  Created by Josh Cotterell on 17/02/2018.
//  Copyright © 2018 Josh Cotterell. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginView: UIView {
    
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
    
    let loginBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("Login", for: .normal)
        btn.backgroundColor = UIColor(r: 0, g: 68, b: 255)
        btn.setTitleColor(.white, for: .normal)
        btn.addTarget(self, action: #selector(loginUser), for: .touchUpInside)
        return btn
    }()
    
    let errorLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Incorrect username or password."
        lbl.textColor = .white
        lbl.backgroundColor = .errorRed
        lbl.isHidden = true
        lbl.textAlignment = .center
        return lbl
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let stackView = UIStackView()
        stackView.addArrangedSubview(emailTextField)
        stackView.addArrangedSubview(passwordTextField)
        stackView.addArrangedSubview(loginBtn)
        stackView.addArrangedSubview(errorLabel)
        
        emailTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        passwordTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        loginBtn.heightAnchor.constraint(equalToConstant: 50).isActive = true
        errorLabel.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
        
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        stackView.axis = .vertical
        stackView.spacing = 10
        
        addSubview(stackView)
        stackView.anchor(nil, bottom: nil, left: self.leftAnchor, right: self.rightAnchor, topConstant: 0, bottomConstant: 0, leftConstant: 20, rightConstant: -20, width: 0, height: 0)
        stackView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        
    }
    
    @objc func loginUser() {
        guard let email = emailTextField.text,
        let password = passwordTextField.text else { return }
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error != nil {
                print(error.debugDescription)
            }
            if user == nil {
                self.errorLabel.isHidden = false
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}







