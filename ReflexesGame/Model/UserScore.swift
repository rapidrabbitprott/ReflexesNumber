//
//  UserScore.swift
//  ReflexesGame
//
//  Created by 森川正崇 on 2020/04/02.
//  Copyright © 2020 morikawamasataka. All rights reserved.
//

import UIKit

class UserScore {
    var calcTypeAndDigits: String
    var calcType: [String]
    var digits: Int
    var finishTime: [String]
    

    init(calcTypeAndDigits: String, calcType: [String], digits: Int, finishTime: [String]) {
        self.calcTypeAndDigits = calcTypeAndDigits
        self.calcType = calcType
        self.digits = digits
        self.finishTime = finishTime
    }

}
