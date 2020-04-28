//
//  YourScoreTableViewCell.swift
//  ReflexesGame
//
//  Created by 森川正崇 on 2020/02/05.
//  Copyright © 2020 morikawamasataka. All rights reserved.
//

import UIKit

protocol YourScoreTableViewCellDelegate {
    func returnHome(tableViewCell: UITableViewCell, button: UIButton)
    func retry(tableViewCell: UITableViewCell, button: UIButton)
}
class YourScoreTableViewCell: UITableViewCell {
    
    var delegate : YourScoreTableViewCellDelegate?
    
    @IBOutlet var userTimeLabel: UILabel!
    @IBOutlet var userRankLabel: UILabel!
    @IBOutlet var homeButton: UIButton!
    @IBOutlet var retryButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    @IBAction func returnHome(button: UIButton){
        self.delegate?.returnHome(tableViewCell: self, button: button)
    }
    
    @IBAction func retry(button: UIButton){
        self.delegate?.retry(tableViewCell: self, button: button)
    }
}
