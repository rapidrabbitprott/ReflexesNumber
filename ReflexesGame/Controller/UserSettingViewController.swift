//
//  UserSettingViewController.swift
//  ReflexesGame
//
//  Created by 森川正崇 on 2020/03/25.
//  Copyright © 2020 morikawamasataka. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import FacebookCore
import FacebookLogin
import Firebase
import PKHUD

class UserSettingViewController: UIViewController {
    
    @IBOutlet var currentNameLabel: UILabel!
    @IBOutlet var newNameTextField: UITextField!
    @IBOutlet var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let userId = Auth.auth().currentUser?.uid {
            Firestore.firestore().collection("users").document(userId).getDocument { (snap, error) in
                if error != nil {
                    print(error)
                } else {
                    let name = snap?.data()?["userName"]
                    self.currentNameLabel.text = name as? String
                }
            }
        }
        
        
    }
    
    @IBAction func saveName(){
        if  newNameTextField.text?.count != 0 {
            let newName = newNameTextField.text!
            let userId = (Auth.auth().currentUser?.uid)!
            Firestore.firestore().collection("users").document(userId).setData(["userName": newName])
            Firestore.firestore().collection("tempUser").document(userId).setData(["tempUserName":newName])
            let alert = UIAlertController(title: "User name changed", message: "back to start", preferredStyle:.alert)
            let action = UIAlertAction(title: "OK", style: .default) { (action) in
                //OKボタンを押した時のアクション
                alert.dismiss(animated: true, completion: nil)
                self.dismiss(animated: true, completion: nil)
            }
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "No name", message: "please enter user name", preferredStyle:.alert)
            let action = UIAlertAction(title: "OK", style: .default) { (action) in
                //OKボタンを押した時のアクション
                alert.dismiss(animated: true, completion: nil)
            }
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func back() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func withdraw() {
        let alert = UIAlertController(title: "Are you sure", message: "if you withdraw, you can`t login this account again", preferredStyle:.alert)
        let deleteAction = UIAlertAction(title: "withdraw", style: .default) { (action) in
            let userId = (Auth.auth().currentUser?.uid)!
            Firestore.firestore().collection("users").document(userId).delete { (error) in
                if error != nil {
                    print(error)
                }
            }
            Auth.auth().currentUser?.delete(completion: { (error) in
                if error != nil {
                    HUD.flash(.labeledError(title: "Delete Failed", subtitle: error?.localizedDescription), delay: 3)
                }
            })
            AccessToken.current = nil
            // ①storyboardのインスタンス取得
            let storyboard: UIStoryboard = self.storyboard!
            // ②遷移先ViewControllerのインスタンス取得
            let nextView = storyboard.instantiateViewController(withIdentifier: "homeStoryboard") as! StartViewController
            nextView.loadView()
            nextView.viewDidLoad()
            nextView.viewWillLayoutSubviews()
            HUD.flash(.labeledSuccess(title: "Withdraw Success",subtitle: "back to start"), delay: 3)
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self.dismiss(animated: true, completion: nil)
            }
            
        }
        
        let cancelAction = UIAlertAction(title: "cancel", style: .cancel) { (action) in
            alert.dismiss(animated: true, completion: nil)
            
        }
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        self.present(alert,animated: true,completion: nil)
        
        
        
    }
    
    
}
