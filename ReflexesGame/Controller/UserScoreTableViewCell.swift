//
//  UserScoreTableViewCell.swift
//  ReflexesGame
//
//  Created by 森川正崇 on 2020/02/24.
//  Copyright © 2020 morikawamasataka. All rights reserved.
//

import UIKit

class UserScoreTableViewCell: UITableViewCell {
    @IBOutlet var calcAndDigitsLabel: UILabel!
    @IBOutlet var bestRecordLablel: UILabel!
    @IBOutlet var secondRecordLabel: UILabel!
    @IBOutlet var thirdRecordLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
}
