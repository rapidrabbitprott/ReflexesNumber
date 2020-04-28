//
//  PlayViewController.swift
//  ReflexesGame
//
//  Created by 森川正崇 on 2020/01/02.
//  Copyright © 2020 morikawamasataka. All rights reserved.
//

import UIKit
import Firebase
import PKHUD

class PlayViewController: UIViewController,GADInterstitialDelegate {
    //timerに関する変数
    @IBOutlet weak var timerLabel: UILabel!
    
    var db: Firestore!
    
    var seconds:Double = 0
    var lap:Double = 0
    var timer = Timer()
    var lapTimers: [Double] = []
    var passedLevel:Int = 0
    var passedCalcType: [String] = []
    var passedConvertCalcType: String = ""
    var calctypeAndDigits: String = ""
    var userName: String = ""
    //buttonに関する定数
    let button_zero = UIButton()
    let button_one = UIButton()
    let button_two = UIButton()
    let button_three = UIButton()
    let button_four = UIButton()
    let button_five = UIButton()
    let button_six = UIButton()
    let button_seven = UIButton()
    let button_eight = UIButton()
    let button_nine = UIButton()
    let button_del = UIButton()
    let button_ad1 = UIButton()
    let button_ad2 = UIButton()
    let button_ad3 = UIButton()
    let button_ad4 = UIButton()
    let button_ad5 = UIButton()
    
    @IBOutlet var problemLabel: UILabel!
    @IBOutlet var answerLabel: UILabel!
    @IBOutlet var questionNumberLabel: UILabel!
    @IBOutlet var judgeImageView: UIImageView!
    
    var types:UInt64 = 0
    var decideOperatorNumber: UInt64 = 0
    var formerNumber: UInt64 = 0
    var latterNumber: UInt64 = 0
    var upperlimit: UInt64 = 0
    var lowerlimit: UInt64 = 0
    var numberofcandidate: UInt64 = 0
    var answer: UInt64 = 0
    var answerForm: String = ""
    var answerFormSkin: String = ""
    var answerDigits: UInt64 = 0
    var entryString: String = ""
    
    var userEntry: UInt64 = 0
    var howManyEntry: Int = 0
    var questionNumber: Int = 1
    
    var countNumber: Int = 0
    //広告に関する変数
    @IBOutlet var bannerView: GADBannerView?
    var interstitial: GADInterstitial!
    override func viewDidLoad() {
        super.viewDidLoad()
        calctypeAndDigits = passedConvertCalcType + String(passedLevel)
        //バナー
        bannerView?.adUnitID = "ca-app-pub-1092380662814917/2106980287"
        bannerView?.rootViewController = self
        bannerView?.load(GADRequest())
        //インターステイシャル
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-1092380662814917/8884162075")
        let request = GADRequest()
        interstitial.load(request)
        interstitial.delegate = self
        //timerのUILabelを自動でリサイズする
        timerLabel.adjustsFontSizeToFitWidth = true
        timer = Timer.scheduledTimer(
            
            timeInterval: 0.01,                              // 時間間隔
            
            target: self,                       // タイマーの実際の処理の場所
            
            selector: #selector(PlayViewController.tickTimer(_:)),   // メソッド タイマーの実際の処理
            
            userInfo: nil,
            
            repeats: true)
        
        
        //スクロール中でもタイマーが動くようにする
        RunLoop.main.add(timer, forMode: RunLoop.Mode.common)
        
        judgeImageView.alpha = 0
        questionNumberLabel.text = "Q" + String(questionNumber)
        var digitNumber: Int = 1
        var dividecandidate: [UInt64] = []
        var answerDigits: UInt64 = 0
        types = UInt64(passedCalcType.count) - 1
        decideOperatorNumber = arc4random(lower: 0, upper: types)
        
        if (passedLevel < 6) {
            for _ in 1 ..< passedLevel {
                digitNumber = digitNumber * 10
            }
            lowerlimit = UInt64(digitNumber)
            upperlimit = UInt64(digitNumber * 10 - 1)
        } else {
            for _ in 1 ..< passedLevel {
                digitNumber = digitNumber * 10
            }
            lowerlimit = 1
            upperlimit = UInt64(digitNumber - 1)
        }
        formerNumber = arc4random(lower: lowerlimit, upper: upperlimit)
        
        //もし演算子が-ならば,latterNumberのupperはformerNumberにする
        if (passedCalcType[Int(decideOperatorNumber)] == "-" ) {
            latterNumber = arc4random(lower: lowerlimit, upper: formerNumber)
            answer = formerNumber - latterNumber
        } else if (passedCalcType[Int(decideOperatorNumber)] == "÷" ) {
            //もし演算子が÷ならば,1formerNumberが素数なら再度選定2素数でないならばランダムで選ぶ
            while (decidedivisor(lower: lowerlimit, number: formerNumber).divisor == []) {
                formerNumber = arc4random(lower: lowerlimit, upper: upperlimit)
            }
            dividecandidate = decidedivisor(lower: lowerlimit, number: formerNumber).divisor
            numberofcandidate = UInt64(dividecandidate.count)
            latterNumber = dividecandidate[Int(arc4random(lower: 0, upper: numberofcandidate))]
            answer = formerNumber/latterNumber
        } else if (passedCalcType[Int(decideOperatorNumber)] == "+") {
            latterNumber = arc4random(lower: lowerlimit, upper: upperlimit)
            answer = formerNumber + latterNumber
        } else {
            latterNumber = arc4random(lower: lowerlimit, upper: upperlimit)
            answer = formerNumber * latterNumber
        }
        answerDigits = checkdigits(number: answer)
        problemLabel.text = String(formerNumber) + " " + String(passedCalcType[Int(decideOperatorNumber)]) + " " +  String(latterNumber)
        answerForm = makeAnswerForm(answer: answerDigits)
        answerFormSkin = answerForm
        //解答欄作成
        answerLabel.text = answerForm
        //回答欄の最後を赤くする
        let attrText1 = NSMutableAttributedString(string: answerLabel.text!)
        
        attrText1.addAttributes([
            .foregroundColor: UIColor.red,
        ], range: NSMakeRange(howManyEntry,1))
        
        answerLabel.attributedText = attrText1
        let screenWidth:CGFloat = self.view.frame.width
        let screenHeight:CGFloat = self.view.frame.height
        let originalPosition = [CGRect(x:0, y:screenHeight - screenWidth/4,width:screenWidth/4, height:screenWidth/4),CGRect(x:screenWidth/4, y:screenHeight - screenWidth/4,width:screenWidth/4, height:screenWidth/4),CGRect(x:2*screenWidth/4, y:screenHeight - screenWidth/4,width:screenWidth/4, height:screenWidth/4),CGRect(x:3*screenWidth/4, y:screenHeight - screenWidth/4,width:screenWidth/4, height:screenWidth/4),CGRect(x:0, y:screenHeight - 2*screenWidth/4,width:screenWidth/4, height:screenWidth/4),CGRect(x:screenWidth/4, y:screenHeight - 2*screenWidth/4,width:screenWidth/4, height:screenWidth/4),CGRect(x:2*screenWidth/4, y:screenHeight - 2*screenWidth/4,width:screenWidth/4, height:screenWidth/4),CGRect(x:3*screenWidth/4, y:screenHeight - 2*screenWidth/4,width:screenWidth/4, height:screenWidth/4),CGRect(x:0, y:screenHeight - 3*screenWidth/4,width:screenWidth/4, height:screenWidth/4),CGRect(x:screenWidth/4, y:screenHeight - 3*screenWidth/4,width:screenWidth/4, height:screenWidth/4),CGRect(x:2*screenWidth/4, y:screenHeight - 3*screenWidth/4,width:screenWidth/4, height:screenWidth/4),CGRect(x:3*screenWidth/4, y:screenHeight - 3*screenWidth/4,width:screenWidth/4, height:screenWidth/4),CGRect(x:0, y:screenHeight - 4*screenWidth/4,width:screenWidth/4, height:screenWidth/4),CGRect(x:screenWidth/4, y:screenHeight - 4*screenWidth/4,width:screenWidth/4, height:screenWidth/4),CGRect(x:2*screenWidth/4, y:screenHeight - 4*screenWidth/4,width:screenWidth/4, height:screenWidth/4),CGRect(x:3*screenWidth/4, y:screenHeight - 4*screenWidth/4,width:screenWidth/4, height:screenWidth/4)]
        let shuffledPositionArray = originalPosition.shuffled()
        let buttonArray = [button_zero,button_one,button_two,button_three,button_four,button_five,button_six,button_seven,button_eight,button_nine,button_ad1,button_ad2,button_ad3,button_ad4,button_ad5,button_del]
        //admobのボタン位置配置の変数
        var arrayNum: UInt64 = 0
        for button in buttonArray {
            
            button.titleLabel?.font =  UIFont.systemFont(ofSize: 30)
            button.backgroundColor = UIColor.hex(string: "#8c8c94", alpha: 1)
            button.frame = shuffledPositionArray[Int(arrayNum)]
            if button == button_del {
                button.setTitleColor(UIColor.red, for: .normal)
                button.setTitle("DEL", for:UIControl.State.normal)
                button.addTarget(self, action: #selector(PlayViewController.delete(sender:)), for: .touchUpInside)
            } else if button == button_ad1 {
                button.setTitleColor(UIColor.green, for: .normal)
                button.setTitle("AD", for:UIControl.State.normal)
                button.addTarget(self, action: #selector(PlayViewController.displayAD(sender:)), for: .touchUpInside)
            } else if button == button_ad2 {
                button.setTitleColor(UIColor.green, for: .normal)
                button.setTitle("AD", for:UIControl.State.normal)
                button.addTarget(self, action: #selector(PlayViewController.displayAD(sender:)), for: .touchUpInside)
            } else if button == button_ad3 {
                button.setTitleColor(UIColor.green, for: .normal)
                button.setTitle("AD", for:UIControl.State.normal)
                button.addTarget(self, action: #selector(PlayViewController.displayAD(sender:)), for: .touchUpInside)
            } else if button == button_ad4 {
                button.setTitleColor(UIColor.green, for: .normal)
                button.setTitle("AD", for:UIControl.State.normal)
                button.addTarget(self, action: #selector(PlayViewController.displayAD(sender:)), for: .touchUpInside)
            } else if button == button_ad5 {
                button.setTitleColor(UIColor.green, for: .normal)
                button.setTitle("AD", for:UIControl.State.normal)
                button.addTarget(self, action: #selector(PlayViewController.displayAD(sender:)), for: .touchUpInside)
            } else if arrayNum <= 9 {
                button.setTitleColor(UIColor.white, for: .normal)
                button.setTitle(String(arrayNum), for:UIControl.State.normal)
            }
            self.view.addSubview(button)
            arrayNum += 1
        }
        button_zero.addTarget(self, action: #selector(PlayViewController.enterzero(sender:)), for: .touchUpInside)
        button_one.addTarget(self, action: #selector(PlayViewController.enterone(sender: )), for: .touchUpInside)
        button_two.addTarget(self, action: #selector(PlayViewController.entertwo(sender:)), for: .touchUpInside)
        button_three.addTarget(self, action: #selector(PlayViewController.enterthree(sender:)), for: .touchUpInside)
        button_four.addTarget(self, action: #selector(PlayViewController.enterfour(sender:)), for: .touchUpInside)
        button_five.addTarget(self, action: #selector(PlayViewController.enterfive(sender:)), for: .touchUpInside)
        button_six.addTarget(self, action: #selector(PlayViewController.entersix(sender:)), for: .touchUpInside)
        button_seven.addTarget(self, action: #selector(PlayViewController.enterseven(sender:)), for: .touchUpInside)
        button_eight.addTarget(self, action: #selector(PlayViewController.entereight(sender:)), for: .touchUpInside)
        button_nine.addTarget(self, action: #selector(PlayViewController.enternine(sender:)), for: .touchUpInside)
        
    }
    
    func arc4random(lower: UInt64, upper: UInt64) -> UInt64 {
        guard upper >= lower else {
            return 0
        }
        
        return UInt64(arc4random_uniform(UInt32(upper - lower))) + lower
    }
    
    func decidedivisor(lower: UInt64, number: UInt64) -> (judge:Bool, divisor: [UInt64]) {
        var judge:Bool = false
        var divisor:[UInt64] = []
        for i in lower ..< number {
            if (number % i == 0) {
                divisor.append(i)
                judge = true
            } else {
                judge = false
            }
            
        }
        return(judge,divisor)
    }
    
    func checkdigits(number: UInt64) -> UInt64 {
        var answer = number
        var numberOfDigits: UInt64 = 1
        while (answer >= 10) {
            answer = answer/10
            numberOfDigits = numberOfDigits + 1
        }
        return numberOfDigits
    }
    
    func makeAnswerForm(answer: UInt64) -> String {
        let number = answer
        if (number == 1) {
            return "_"
        } else if (number == 2) {
            return "_ _"
        } else if (number == 3) {
            return "_ _ _"
        } else if (number == 4) {
            return "_ _ _ _"
        } else if (number == 5) {
            return "_ _ _ _ _"
        } else if (number == 6) {
            return "_ _ _ _ _ _"
        } else if (number == 7) {
            return "_ _ _ _ _ _ _"
        } else if (number == 8){
            return "_ _ _ _ _ _ _ _"
        } else if (number == 9) {
            return "_ _ _ _ _ _ _ _ _"
        } else  {
            return "_ _ _ _ _ _ _ _ _ _"
        }
    }
    
    func entry(entry:UInt64) {
        //①answerlabelの最初2つを削除②削除した上で最後を赤くする③ユーザーエントリーを最後に追加
        howManyEntry += 1
        if (howManyEntry <= checkdigits(number: answer) - 1) {
            entryString.append(String(entry))
            answerFormSkin.removeLast()
            answerFormSkin.removeLast()
            answerForm = entryString + answerFormSkin
            let attrText1 = NSMutableAttributedString(string: answerForm)
            
            attrText1.addAttributes([
                .foregroundColor: UIColor.red,
            ], range: NSMakeRange(howManyEntry,1))
            
            answerLabel.attributedText = attrText1
            
        }else if(howManyEntry == checkdigits(number: answer)) {
            entryString.append(String(entry))
            answerForm = entryString
            answerLabel.text = answerForm
            if (UInt64(answerForm) == answer) {
                questionNumber += 1
                judgeImageView.image = UIImage(systemName: "circle")
                judgeImageView.tintColor = UIColor.systemGreen
                judgeImageView.alpha = 1
                timer.invalidate()
                DispatchQueue.main.asyncAfter( deadline: DispatchTime.now() + 1.0 ) {
                    self.answer = 0
                    self.entryString = ""
                    self.howManyEntry = 0
                    //10問正解したら次の画面に値渡し(本来は11にすべきだが，今回は簡単にテストをしたいので2に変更)
                    if (self.questionNumber != 2) {
                        self.loadView()
                        self.viewDidLoad()
                    } else {
                        self.timer.invalidate()
                        self.sendScore()
                        //インターステーシャル広告を実装する!!!
                        //あらかじめscoreの内容をセットしておく
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            
                            Firestore.firestore().collection(self.calctypeAndDigits).document("scoreCount").getDocument { (snap, error) in

                                self.countNumber = snap?.data()!["scoreCount"] as! Int
                                
                            }
                            
                        }
                        
                        HUD.flash(.progress, onView: self.view, delay: 5) { _ in
                            // HUDを非表示にしたあとの処理
                            self.performSegue(withIdentifier: "toResult", sender: nil)
                        }
                        
                    }
                }
                
            } else {
                judgeImageView.image = UIImage(systemName: "multiply")
                judgeImageView.tintColor = UIColor.systemRed
                judgeImageView.alpha = 1
                DispatchQueue.main.asyncAfter( deadline: DispatchTime.now() + 1.0 ) {
                    self.howManyEntry = 0
                    self.answerDigits = self.checkdigits(number: self.answer)
                    self.answerForm = self.makeAnswerForm(answer: self.answerDigits)
                    self.answerFormSkin = self.answerForm
                    self.entryString = ""
                    //解答欄作成
                    self.answerLabel.text = self.answerForm
                    self.judgeImageView.alpha = 0
                }
            }
        }
    }
    
    
    
    @objc func tickTimer(_ timer: Timer) {
        
        seconds += 1
        
        timerLabel.text = timeString(time: seconds)
    }
    
    func timeString(time:TimeInterval) -> String {
        let minutes = Int(time) / 100 / 60 % 60//分
        let seconds = Int(time) / 100 % 60//秒
        let milliseconds = Int(time) % 100//ミリ秒
        //時が０の時に時までの時間を表示
        return String(format:"%02d:%02d:%02d", minutes, seconds,milliseconds)
    }
    
    @objc func enterzero(sender: Any) {
        userEntry = 0
        entry(entry: userEntry)
    }
    
    @objc func enterone(sender: Any) {
        userEntry = 1
        entry(entry: userEntry)
    }
    
    @objc func entertwo(sender: Any) {
        userEntry = 2
        entry(entry: userEntry)
    }
    
    @objc func enterthree(sender: Any) {
        userEntry = 3
        entry(entry: userEntry)
    }
    
    @objc func enterfour(sender: Any) {
        userEntry = 4
        entry(entry: userEntry)
    }
    
    @objc func enterfive(sender: Any) {
        userEntry = 5
        entry(entry: userEntry)
    }
    
    @objc func entersix(sender: Any) {
        userEntry = 6
        entry(entry: userEntry)
    }
    
    @objc func enterseven(sender: Any) {
        userEntry = 7
        entry(entry: userEntry)
    }
    
    @objc func entereight(sender: Any) {
        userEntry = 8
        entry(entry: userEntry)
    }
    
    @objc func enternine(sender: Any) {
        userEntry = 9
        entry(entry: userEntry)
    }
    
    @objc func delete(sender: Any) {
        if (howManyEntry != 0) {
            howManyEntry -= 1
            entryString.removeLast()
            answerFormSkin.append(" _")
            answerForm = entryString + answerFormSkin
            let attrText1 = NSMutableAttributedString(string: answerForm)
            
            attrText1.addAttributes([
                .foregroundColor: UIColor.red,
            ], range: NSMakeRange(howManyEntry,1))
            
            answerLabel.attributedText = attrText1
        }
    }
    
    @objc func displayAD(sender: Any) {
        if interstitial.isReady {
            interstitial.present(fromRootViewController: self)
        } else {
            print("Ad wasn't ready")
        }
    }
    
    func createAndLoadInterstitial() -> GADInterstitial {
        var interstitial = GADInterstitial(adUnitID: "ca-app-pub-1092380662814917/8884162075")
        interstitial.delegate = self
        interstitial.load(GADRequest())
        return interstitial
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        interstitial = createAndLoadInterstitial()
    }
    
    func sendScore () {
        if let userId = Auth.auth().currentUser?.uid {
            Firestore.firestore().collection(calctypeAndDigits).document(userId).setData([
                "finishTime": timeString(time: seconds),
                "userId": userId,
                "calcType": passedCalcType,
                "digits": passedLevel], merge: true)
            Firestore.firestore().collection(calctypeAndDigits).document("scoreCount").getDocument { (document, error) in
                if let document = document, document.exists {
                    print("doc exists")
                } else {
                    Firestore.firestore().collection(self.calctypeAndDigits).document("scoreCount").setData([
                        "scoreCount":-1])
                }
            }
            Firestore.firestore().collection(userId).document(calctypeAndDigits).getDocument { (snap, error) in
                if let snap = snap, snap.exists {
                    Firestore.firestore().collection(userId).document(self.calctypeAndDigits).updateData(["finishTime": FieldValue.arrayUnion([self.timeString(time: self.seconds)])])
                } else {
                    Firestore.firestore().collection(userId).document(self.calctypeAndDigits).setData([
                        "calcTypeAndDigits":self.calctypeAndDigits
                        ,"calcType": self.passedCalcType
                        ,"digits": self.passedLevel
                        ,"finishTime":[self.timeString(time: self.seconds)]])
                }
            }
            
        }
        
    }
    
    //値渡しのコード
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let resultViewController = segue.destination as! ResultViewController
        resultViewController.passedFinishTime = timeString(time: seconds)
        resultViewController.passedCalcType = passedCalcType
        resultViewController.passedConvertedCalcType = passedConvertCalcType
        resultViewController.passedLevel = passedLevel
        resultViewController.calctypeAndDigits = calctypeAndDigits
    }
    
}

extension UIColor {
    class func hex ( string : String, alpha : CGFloat) -> UIColor {
        let string_ = string.replacingOccurrences(of: "#", with: "")
        let scanner = Scanner(string: string_ as String)
        var color: UInt32 = 0
        if scanner.scanHexInt32(&color) {
            let r = CGFloat((color & 0xFF0000) >> 16) / 255.0
            let g = CGFloat((color & 0x00FF00) >> 8) / 255.0
            let b = CGFloat(color & 0x0000FF) / 255.0
            return UIColor(red:r,green:g,blue:b,alpha:alpha)
        } else {
            return UIColor.white;
        }
    }
}


