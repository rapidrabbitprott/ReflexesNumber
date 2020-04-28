//
//  SettingViewController.swift
//  ReflexesGame
//
//  Created by 森川正崇 on 2020/01/02.
//  Copyright © 2020 morikawamasataka. All rights reserved.
//

import UIKit
import GoogleMobileAds
class SettingViewController: UIViewController {
    @IBOutlet var plusButton: UIButton!
    @IBOutlet var minusButton: UIButton!
    @IBOutlet var timesButton: UIButton!
    @IBOutlet var divideButton: UIButton!
    @IBOutlet var allButton: UIButton!
    @IBOutlet var oneButton: UIButton!
    @IBOutlet var twoButton: UIButton!
    @IBOutlet var threeButton: UIButton!
    @IBOutlet var fourButton: UIButton!
    @IBOutlet var fiveButton: UIButton!
    @IBOutlet var readyButton: UIButton!
    
    var calcType: [String] = []
    var level: Int = 0
    var convertCalcType: String = ""
    var convertChar : String = ""
    let convertDict = ["+":"plus","-":"minus","×":"multiply","÷":"divide"]
    override func viewDidLoad() {
        super.viewDidLoad()
        designButton(button: plusButton)
        designButton(button: minusButton)
        designButton(button: timesButton)
        designButton(button: divideButton)
        designButton(button: allButton)
        designButton(button: oneButton)
        designButton(button: twoButton)
        designButton(button: threeButton)
        designButton(button: fourButton)
        designButton(button: fiveButton)
        designButton(button: readyButton)
        
    }
    
    
    func designButton(button: UIButton) {
        button.layer.cornerRadius = 10.0
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.5 // 透明度
        button.layer.shadowOffset = CGSize(width: 5, height: 5) // 距離
        button.layer.shadowRadius = 10 // ぼかし量
    }
    
    @IBAction func plus(button: UIButton) {
        if (button.titleLabel?.textColor == UIColor.red) {
            button.setTitleColor(UIColor.white, for: .normal)
            calcType.remove(value: "+")
        } else {
            button.setTitleColor(UIColor.red, for: .normal)
            calcType.append("+")
        }
        ready()
    }
    
    @IBAction func minus(button: UIButton) {
        if (button.titleLabel?.textColor == UIColor.red) {
            button.setTitleColor(UIColor.white, for: .normal)
            calcType.remove(value: "-")
        } else {
            button.setTitleColor(UIColor.red, for: .normal)
            calcType.append("-")
        }
        ready()
    }
    
    @IBAction func times(button: UIButton) {
        if (button.titleLabel?.textColor == UIColor.red) {
            button.setTitleColor(UIColor.white, for: .normal)
            calcType.remove(value: "×")
        } else {
            button.setTitleColor(UIColor.red, for: .normal)
            calcType.append("×")
        }
        ready()
    }
    
    @IBAction func divide(button: UIButton) {
        if (button.titleLabel?.textColor == UIColor.red) {
            button.setTitleColor(UIColor.white, for: .normal)
            calcType.remove(value: "÷")
        } else {
            button.setTitleColor(UIColor.red, for: .normal)
            calcType.append("÷")
        }
        ready()
    }
    
    @IBAction func one(button: UIButton) {
        if (button.titleLabel?.textColor == UIColor.red) {
            button.setTitleColor(UIColor.white, for: .normal)
            level = 0
        } else {
            button.setTitleColor(UIColor.red, for: .normal)
            level = 1
            twoButton.setTitleColor(UIColor.white, for: .normal)
            threeButton.setTitleColor(UIColor.white, for: .normal)
            fourButton.setTitleColor(UIColor.white, for: .normal)
            fiveButton.setTitleColor(UIColor.white, for: .normal)
            allButton.setTitleColor(UIColor.white, for: .normal)
        }
        ready()
    }
    
    @IBAction func two(button: UIButton) {
        if (button.titleLabel?.textColor == UIColor.red) {
            button.setTitleColor(UIColor.white, for: .normal)
            level = 0
        } else {
            button.setTitleColor(UIColor.red, for: .normal)
            level = 2
            oneButton.setTitleColor(UIColor.white, for: .normal)
            threeButton.setTitleColor(UIColor.white, for: .normal)
            fourButton.setTitleColor(UIColor.white, for: .normal)
            fiveButton.setTitleColor(UIColor.white, for: .normal)
            allButton.setTitleColor(UIColor.white, for: .normal)
        }
        ready()
    }
    
    @IBAction func three(button: UIButton) {
        if (button.titleLabel?.textColor == UIColor.red) {
            button.setTitleColor(UIColor.white, for: .normal)
            level = 0
        } else {
            button.setTitleColor(UIColor.red, for: .normal)
            level = 3
            oneButton.setTitleColor(UIColor.white, for: .normal)
            twoButton.setTitleColor(UIColor.white, for: .normal)
            fourButton.setTitleColor(UIColor.white, for: .normal)
            fiveButton.setTitleColor(UIColor.white, for: .normal)
            allButton.setTitleColor(UIColor.white, for: .normal)
        }
        ready()
    }
    
    @IBAction func four(button: UIButton) {
        if (button.titleLabel?.textColor == UIColor.red) {
            button.setTitleColor(UIColor.white, for: .normal)
            level = 0
        } else {
            button.setTitleColor(UIColor.red, for: .normal)
            level = 4
            oneButton.setTitleColor(UIColor.white, for: .normal)
            twoButton.setTitleColor(UIColor.white, for: .normal)
            threeButton.setTitleColor(UIColor.white, for: .normal)
            fiveButton.setTitleColor(UIColor.white, for: .normal)
            allButton.setTitleColor(UIColor.white, for: .normal)
        }
        ready()
    }
    
    @IBAction func five(button: UIButton) {
        if (button.titleLabel?.textColor == UIColor.red) {
            button.setTitleColor(UIColor.white, for: .normal)
            level = 0
        } else {
            button.setTitleColor(UIColor.red, for: .normal)
            level = 5
            oneButton.setTitleColor(UIColor.white, for: .normal)
            twoButton.setTitleColor(UIColor.white, for: .normal)
            threeButton.setTitleColor(UIColor.white, for: .normal)
            fourButton.setTitleColor(UIColor.white, for: .normal)
            allButton.setTitleColor(UIColor.white, for: .normal)
        }
        ready()
    }
    
    @IBAction func all(button: UIButton) {
        if (button.titleLabel?.textColor == UIColor.red) {
            button.setTitleColor(UIColor.white, for: .normal)
            level = 0
        } else {
            button.setTitleColor(UIColor.red, for: .normal)
            level = 6
            oneButton.setTitleColor(UIColor.white, for: .normal)
            twoButton.setTitleColor(UIColor.white, for: .normal)
            threeButton.setTitleColor(UIColor.white, for: .normal)
            fourButton.setTitleColor(UIColor.white, for: .normal)
            fiveButton.setTitleColor(UIColor.white, for: .normal)
        }
        ready()
    }
    
    @IBAction func transitPlayScreen() {
        for char in calcType{
            convertChar += convertDict[char]!
        }
        performSegue(withIdentifier: "toPlay", sender: nil)
    }
    
    @IBAction func back() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func ready() {
        if (level != 0 && calcType.count != 0) {
            readyButton.isEnabled = true
            readyButton.setTitleColor(UIColor.green, for: .normal)
        } else {
            readyButton.isEnabled = false
            readyButton.setTitleColor(UIColor.darkGray, for: .normal)
        }
        calcType.sort()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //次の画面を取得
        let playViewController = segue.destination as! PlayViewController
        playViewController.passedLevel = level
        playViewController.passedCalcType = calcType
        playViewController.passedConvertCalcType = convertChar
    }
}

extension Array where Element: Equatable {
    mutating func remove(value: Element) {
        if let i = self.index(of: value) {
            self.remove(at: i)
        }
    }
}
