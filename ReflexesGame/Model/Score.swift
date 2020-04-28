//
//  Score.swift
//  ReflexesGame
//
//  Created by 森川正崇 on 2020/02/24.
//  Copyright © 2020 morikawamasataka. All rights reserved.
//

import UIKit

class Score {
    var objectId: String
    var finishTime: String
    var calcType: [String]
    var digits: Int

    init(objectId: String, finishTime: String, calcType: [String],digits: Int) {
        self.objectId = objectId
        self.finishTime = finishTime
        self.calcType = calcType
        self.digits = digits
    }

}
