//
//  EmailRegisterViewController.swift
//  ReflexesGame
//
//  Created by 森川正崇 on 2020/02/24.
//  Copyright © 2020 morikawamasataka. All rights reserved.
//

import UIKit
import Firebase
import PKHUD



@objc(EmailRegisterViewController)
class EmailRegisterViewController: UIViewController,UITextFieldDelegate {
    var db: Firestore!
    @IBOutlet weak var userNameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var passwordConfirmationField: UITextField!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var logInButton: UIButton!
    
    @IBOutlet weak var alertLabel: UILabel!
    
    var link: String!
    
    // UserDefaults のインスタンス
    let userDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userNameField.delegate = self
        passwordField.delegate = self
        emailField.delegate = self
        passwordConfirmationField.delegate = self
        
        // デフォルト値
        userDefaults.register(defaults: ["DataStore": "default"])
        
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        confirmEntry()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        confirmEntry()
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        confirmEntry()
        return true
    }
    
    
    @IBAction func login() {
        HUD.show(.progress)
        Auth.auth().signIn(withEmail: emailField.text!, password: passwordField.text!) { [weak self] user, error in guard self != nil else {return}
            if error != nil {
                HUD.flash(.labeledError(title: "Login Failed", subtitle: error?.localizedDescription), delay: 3)
                return
            } else {
                HUD.flash(.success, onView: self?.view, delay: 3) { _ in
                    self!.dismiss(animated: true, completion: nil)
                }
            }
        }
        
    }
    
    @IBAction func register() {
        HUD.show(.progress)
        signUp(email: emailField.text!, password: passwordField.text!, name: userNameField.text!)
    }
    
    private func signUp(email: String, password: String, name: String) {
        Auth.auth().createUser(withEmail: email, password: password) { authresult, error in
            if error != nil {
                HUD.flash(.labeledError(title: "Register Failed", subtitle: error?.localizedDescription), delay: 3)
            }
            self.updateDisplayName(name: name)
        }
    }
    
    private func updateDisplayName(name: String) {
        Firestore.firestore().collection("tempUser").document(Auth.auth().currentUser!.uid).setData(["tempUserName":name])
        
        self.sendEmailVerification()
        
    }
    
    
    private func sendEmailVerification() {
        Auth.auth().currentUser?.sendEmailVerification() { error in
            if error != nil {
                HUD.flash(.labeledError(title: "Register Failed", subtitle: error?.localizedDescription), delay: 3)
            }
            self.showSignUpCompletion()
        }
    }
    
    private func showSignUpCompletion() {
        HUD.show(.labeledSuccess(title: "Temporaly registered", subtitle: "please check e-mail, and restart this App"))
    }
    
    func confirmEntry() {
        if (passwordField.text != "") && (passwordField.text == passwordConfirmationField.text) && (userNameField.text != "") && (emailField.text != "") {
            registerButton.isEnabled = true
            logInButton.isEnabled = true
            let okCollor = UIColor.systemGreen
            registerButton.setTitleColor(okCollor, for: .normal)
            logInButton.setTitleColor(okCollor, for: .normal)
        }
        if (emailField.text != "") {
            forgotPasswordButton.isEnabled = true
        }
        Firestore.firestore().collection("users").whereField("userName", isEqualTo:userNameField.text!).getDocuments { (snap, error) in
            if snap?.documents != [] {
                self.userNameField.textColor = UIColor.red
                self.alertLabel.text = "if you wanna register,unfortunately this name has been used"
                self.alertLabel.textColor = UIColor.red
            } else {
                self.userNameField.textColor = UIColor.black
                self.alertLabel.text = nil
                self.alertLabel.textColor = UIColor.black
            }
        }
    }
    
    @IBAction func sendPassword() {
        HUD.show(.progress)
        Auth.auth().sendPasswordReset(withEmail: emailField.text!) {error in
            if error != nil {
                HUD.flash(.labeledError(title: "Register Failed", subtitle: error?.localizedDescription), delay: 3)
            } else {
                HUD.show(.labeledSuccess(title: "E-mail sended", subtitle: "please check e-mail"))
            }
        }
    }
    
    
    
    @IBAction func back() {
        self.dismiss(animated: true, completion: nil)
    }
}
