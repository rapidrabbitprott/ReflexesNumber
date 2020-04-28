//
//  StartViewController.swift
//  ReflexesGame
//
//  Created by 森川正崇 on 2020/01/02.
//  Copyright © 2020 morikawamasataka. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import FacebookCore
import FacebookLogin
import Firebase
import GoogleMobileAds
import PKHUD

//AppleSignInに必要なライブラリ
import AuthenticationServices
import CryptoKit

class StartViewController: UIViewController,LoginButtonDelegate{
    
    // Unhashed nonce.
    fileprivate var currentNonce: String?
    
    var userProfile : NSDictionary = [:]
    let fbLoginButton:FBLoginButton = FBLoginButton()
    var displayName = String()
    var pictureURL = String()
    var pictureURLString = String()
    var handle: AuthStateDidChangeListenerHandle?
    var db: Firestore!
    let userDefaults = UserDefaults.standard
    var userScores = [UserScore]()
    var countScores: Int = 0
    @IBOutlet var emailLoginAndRegisterButton: UIButton!
    @IBOutlet var emailLoginAndRegisterLabel: UILabel!
    @IBOutlet var yourScoreButton: UIButton!
    @IBOutlet var settingButton: UIButton!
    @IBOutlet var settingLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fbLoginButton.delegate = self
        fbLoginButton.frame = CGRect(x: view.frame.size.width/4, y: view.frame.size.height/4, width: view.frame.size.width/2, height: 30)
        fbLoginButton.permissions = ["public_profile,email"]
        view.addSubview(fbLoginButton)
        confirmUserStatas()
        resendOrreregister()
        if #available(iOS 13.0, *) {
            // ここでインスタンス(ボタン)を生成
            let appleLoginButton = ASAuthorizationAppleIDButton(
                authorizationButtonType: .default,
                authorizationButtonStyle: .whiteOutline
            )
            // ボタン押した時にhandleTappedAppleLoginButtonの関数を呼ぶようにセット
            appleLoginButton.addTarget(
                self,
                action: #selector(handleTappedAppleLoginButton(_:)),
                for: .touchUpInside
            )
            // ↓はレイアウトの設定
            // これを入れないと下の方で設定したAutoLayoutが崩れる
            appleLoginButton.translatesAutoresizingMaskIntoConstraints = false
            // Viewに追加
            view.addSubview(appleLoginButton)
            
            // ↓はAutoLayoutの設定
            // appleLoginButtonの中心を画面の中心にセットする
            appleLoginButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
            appleLoginButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
            // appleLoginButtonの幅は、親ビューの幅の0.7倍
            appleLoginButton.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.5).isActive = true
            // appleLoginButtonの高さは40
            appleLoginButton.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
            if Auth.auth().currentUser != nil {
                appleLoginButton.isHidden = true
            }
        }
    }
    
    @available(iOS 13.0, *)
    @objc func handleTappedAppleLoginButton(_ sender: ASAuthorizationAppleIDButton) {
        // ランダムの文字列を生成
        let nonce = randomNonceString()
        // delegateで使用するため代入
        currentNonce = nonce
        // requestを作成
        let request = ASAuthorizationAppleIDProvider().createRequest()
        // sha256で変換したnonceをrequestのnonceにセット
        request.nonce = sha256(nonce)
        // controllerをインスタンス化する(delegateで使用するcontroller)
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
    func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if length == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        return result
    }
    // ⑤SHA256を使用してハッシュ変換する関数を用意
    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    @IBAction func handleBackViewButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    override func viewDidLayoutSubviews() {
        confirmUserStatas()
        loginButtonDidLogin(fbLoginButton)
        //        resendOrreregister()
        confirmUserStatas()
    }
    
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        if error == nil {
            if result?.isCancelled == true {
                return
            }
        }
        let credential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current!.tokenString)
        Auth.auth().signIn(with: credential) { (result, error) in
            if let error = error {
                return
            }
            self.displayName = result!.user.displayName!
            self.pictureURLString = result!.user.photoURL!.absoluteString
            self.pictureURLString = self.pictureURLString + "?type=large"
            UserDefaults.standard.set(1, forKey: "loginOk")
            UserDefaults.standard.set(self.displayName, forKey: "displayName")
            let nextVC = self.storyboard?.instantiateViewController(identifier: "settingStoryboard") as! SettingViewController
            
            self.navigationController?.pushViewController(nextVC, animated: true)
        }
        loadView()
        viewDidLoad()
        viewWillLayoutSubviews()
    }
    
    
    //値渡しのコード
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toUserScore" {
            let nextViewController = segue.destination as! UserScoreViewController
            nextViewController.countScores = countScores
            nextViewController.userScores = userScores
        }
        
    }
    
    @IBAction func emailloginLogoutButton() {
        if Auth.auth().currentUser != nil {
            do {
                try Auth.auth().signOut()
                HUD.flash(.labeledSuccess(title: "Logout Success", subtitle: "please wait a few seconds"), delay: 3)
                loadView()
                viewDidLoad()
            } catch let error {
                HUD.flash(.labeledError(title: "Logout Failed", subtitle: error.localizedDescription), delay: 3)
            }
        } else {
            //遷移させる(このとき、prepareForSegue関数で値を渡す)
            self.performSegue(withIdentifier: "toLoginAndRegister", sender: nil)
        }
    }
    
    @IBAction func toUserScore() {
        
        Firestore.firestore().collection(Auth.auth().currentUser!.uid).getDocuments { (snap, error) in
            self.countScores = snap?.count as! Int
        }
        loadUserScores()
        HUD.flash(.progress, onView: self.view, delay: 5) { _ in
            // HUDを非表示にしたあとの処理
            self.performSegue(withIdentifier: "toUserScore", sender: nil)
        }
    }
    
    func loginButtonWillLogin(_ loginButton: FBLoginButton) -> Bool {
        return true
    }
    
    func loginButtonDidLogin(_ loginButton:FBLoginButton) {
        let graphRequest : GraphRequest =
            GraphRequest(graphPath: "me",
                         parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"])
        
        graphRequest.start(completionHandler: { (connection, result, error) -> Void in
            if ((error) != nil) {
                print("Error: \(String(describing: error))")
            } else {
                // プロフィール情報をディクショナリに入れる
                self.userProfile = (result as! NSDictionary)
                // 名前
                let name: String = self.userProfile.object(forKey: "name") as? String ?? ""
                if let userId = Auth.auth().currentUser?.uid {
                    Firestore.firestore().collection("users").document(userId).getDocument { (snap, error) in
                        if snap?.data()?["userName"] == nil {
                            Firestore.firestore().collection("users").document(userId).setData(["userName": name])
                        }
                    }
                    
                }
            }
        })
        
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        confirmUserStatas()
    }
    private func showSignUpCompletion() {
        HUD.show(.labeledSuccess(title: "Temporaly registered", subtitle: "please check e-mail, and restart this App"))
    }
    
    func resendOrreregister() {
        if Auth.auth().currentUser?.isEmailVerified == false {
            Auth.auth().currentUser?.reload(completion: { (error) in
                if error != nil {
                    HUD.flash(.labeledError(title: "Send Failed", subtitle: "please re-register"), delay: 3)
                } else {
                    
                }
            })
            let alert = UIAlertController(title: "Not authorized", message: "please check email or re-register", preferredStyle:.alert)
            let reRegister = UIAlertAction(title: "Re-register", style: .default) { (action) in
                Auth.auth().currentUser?.delete(completion: { (error) in
                    if error != nil {
                        HUD.show(.labeledError(title: "Delete Failed", subtitle: error?.localizedDescription))
                    } else {
                        self.yourScoreButton.isEnabled = false
                        self.yourScoreButton.setTitleColor(UIColor.gray, for: .normal)
                        self.emailLoginAndRegisterLabel.text = "Login/Register\r\n(via e-mail)"
                        self.emailLoginAndRegisterLabel.textColor = UIColor.white
                        self.fbLoginButton.isHidden = false
                        HUD.flash(.labeledSuccess(title: "Please wait a few secounds", subtitle: "reloading"), delay: 3)
                    }
                })
            }
            let resendEmail = UIAlertAction(title:"Re-send email", style: .default) {(action) in
                //OKボタンを押した時のアクション
                Auth.auth().currentUser?.sendEmailVerification() { error in
                    if error != nil {
                        HUD.flash(.labeledError(title: "Send Failed", subtitle: "please re-register"), delay: 3)
                        Auth.auth().currentUser?.delete(completion: { (error) in
                            self.yourScoreButton.isEnabled = false
                            self.yourScoreButton.setTitleColor(UIColor.gray, for: .normal)
                            self.emailLoginAndRegisterLabel.text = "Login/Register\r\n(via e-mail)"
                            self.emailLoginAndRegisterLabel.textColor = UIColor.white
                            self.fbLoginButton.isHidden = false
                            if error != nil {
                                HUD.flash(.labeledError(title: "Fail", subtitle: "please re-register by another email address"), delay: 3)
                            } else {
                                HUD.flash(.labeledError(title: "Fail", subtitle: "please re-register"), delay: 3)
                            }
                        })
                    } else {
                        self.showSignUpCompletion()
                    }
                }
                alert.dismiss(animated: true, completion: nil)
            }
            alert.addAction(resendEmail)
            alert.addAction(reRegister)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func confirmUserStatas() {
        if Auth.auth().currentUser != nil && AccessToken.current == nil{
            //emailのユーザー情報のみある時
            emailLoginAndRegisterButton.isHidden = false
            emailLoginAndRegisterLabel.isHidden = false
            emailLoginAndRegisterLabel.text = "LOGOUT"
            emailLoginAndRegisterLabel.textColor = UIColor.red
            yourScoreButton.isEnabled = true
            yourScoreButton.setTitleColor(UIColor.white, for: .normal)
            fbLoginButton.isHidden = true
            settingButton.isHidden = false
            settingLabel.isHidden = false
            
        } else if  Auth.auth().currentUser == nil && AccessToken.current == nil{
            //emailのユーザー情報もfacebookのユーザー情報もないとき
            yourScoreButton.isEnabled = false
            yourScoreButton.setTitleColor(UIColor.gray, for: .normal)
            emailLoginAndRegisterButton.isHidden = false
            emailLoginAndRegisterLabel.isHidden = false
            fbLoginButton.isHidden = false
            settingButton.isHidden = true
            settingLabel.isHidden = true
            
        } else if AccessToken.current != nil {
            //facebookのユーザー情報のみある時
            yourScoreButton.isEnabled = true
            emailLoginAndRegisterButton.isHidden = true
            emailLoginAndRegisterLabel.isHidden = true
            settingButton.isHidden = false
            settingLabel.isHidden = false
            
        } else {
            //何の情報もない時
            emailLoginAndRegisterButton.isHidden = false
            emailLoginAndRegisterLabel.isHidden = false
            settingButton.isHidden = true
            settingLabel.isHidden = true
            
        }
    }
    
    func loadUserScores() {
        self.userScores = [UserScore]()
        Firestore.firestore().collection(Auth.auth().currentUser!.uid).order(by: "calcTypeAndDigits").getDocuments { (snaps, error) in
            for result in snaps!.documents {
                let finishTime = result.data()["finishTime"] as! [String]
                let calcType = result.data()["calcType"] as! [String]
                let digits = result.data()["digits"] as! Int
                let calcTypeAndDigits = calcType.joined() + String(digits)
                let scoreset = UserScore(calcTypeAndDigits: calcTypeAndDigits, calcType: calcType, digits: digits, finishTime: finishTime)
                self.userScores.append(scoreset)
            }
        }
    }
    
}

// ⑥extensionでdelegate関数に追記していく
extension StartViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    // 認証が成功した時に呼ばれる関数
    func authorizationController(controller _: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        // credentialが存在するかチェック
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            return
        }
        // nonceがセットされているかチェック
        guard let nonce = currentNonce else {
            fatalError("Invalid state: A login callback was received, but no login request was sent.")
        }
        // credentialからtokenが取得できるかチェック
        guard let appleIDToken = appleIDCredential.identityToken else {
            print("Unable to fetch identity token")
            return
        }
        // tokenのエンコードを失敗
        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
            return
        }
        // 認証に必要なcredentialをセット
        let credential = OAuthProvider.credential(
            withProviderID: "apple.com",
            idToken: idTokenString,
            rawNonce: nonce
        )
        // Firebaseへのログインを実行
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                print(error)
                // 必要に応じて
                HUD.flash(.labeledError(title: "Error", subtitle: "please try another way"), delay: 1)
                return
            }
            if let authResult = authResult {
                //名前がなかったらuseridが名前になる
                if let userId = Auth.auth().currentUser?.uid {
                    Firestore.firestore().collection("users").document(userId).getDocument { (snap, error) in
                        if snap?.data()?["userName"] == nil {
                            Firestore.firestore().collection("users").document(userId).setData(["userName": userId])
                        }
                    }
                    
                }
                // 必要に応じて
                HUD.flash(.labeledSuccess(title: "Login Success", subtitle: nil), onView: self.view, delay: 1) { _ in
                    // 画面遷移など行う
                }
            }
        }
    }
    
    // delegateのプロトコルに設定されているため、書いておく
    func presentationAnchor(for _: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
    // Appleのログイン側でエラーがあった時に呼ばれる
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        print("Sign in with Apple errored: \(error)")
    }
    
    
}
