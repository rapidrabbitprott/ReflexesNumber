//
//  RankingTableViewCell.swift
//  ReflexesGame
//
//  Created by 森川正崇 on 2020/02/05.
//  Copyright © 2020 morikawamasataka. All rights reserved.
//

import UIKit

class RankingTableViewCell: UITableViewCell {
    @IBOutlet var rankLabel: UILabel!
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var userTimeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
