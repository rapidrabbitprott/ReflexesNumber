//
//  UserScoreViewController.swift
//  ReflexesGame
//
//  Created by 森川正崇 on 2020/04/02.
//  Copyright © 2020 morikawamasataka. All rights reserved.
//

import UIKit
import Firebase

class UserScoreViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    var countScores: Int = 0
    var bestRecord: String = ""
    var secondRecord: String = ""
    var thirdRecord: String = ""
    var calcTypeAndDigits: String = ""
    var userScores = [UserScore]()
    
    @IBOutlet var yourResultTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setRefreshControl()
        //データ・ソースメソッドをこのファイル内で処理する
        yourResultTableView.dataSource = self
        //このセルが選択された時に処理を実行する。
        yourResultTableView.delegate = self
        //TableViewの不要な線を消す
        yourResultTableView.tableFooterView = UIView()
        //TableViewの高さを動的に決める
        yourResultTableView.rowHeight = UITableView.automaticDimension
        //カスタムセルの登録(TableView上のcellの名前は関係ない！)
        let nib1 = UINib(nibName: "UserScoreTableViewCell", bundle: Bundle.main)
        yourResultTableView.register(nib1, forCellReuseIdentifier: "UserScoreTableViewCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        yourResultTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.countScores
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let yourScoreCell = tableView.dequeueReusableCell(withIdentifier: "UserScoreTableViewCell") as! UserScoreTableViewCell
        yourScoreCell.calcAndDigitsLabel.text = "Type: " + userScores[indexPath.row].calcTypeAndDigits
        userScores[indexPath.row].finishTime.sort()
        if userScores[indexPath.row].finishTime.count >= 3 {
            yourScoreCell.bestRecordLablel.text = "Best Record: " + userScores[indexPath.row].finishTime[0]
            yourScoreCell.secondRecordLabel.text = "2nd Record: " + userScores[indexPath.row].finishTime[1]
            yourScoreCell.thirdRecordLabel.text = "3rd Record: " + userScores[indexPath.row].finishTime[3]
        } else if userScores[indexPath.row].finishTime.count == 2 {
            yourScoreCell.bestRecordLablel.text = "Best Record: " + userScores[indexPath.row].finishTime[0]
            yourScoreCell.secondRecordLabel.text = "2nd Record: " + userScores[indexPath.row].finishTime[1]
            yourScoreCell.thirdRecordLabel.text = thirdRecord
            
        } else if userScores[indexPath.row].finishTime.count == 1 {
            yourScoreCell.bestRecordLablel.text = "Best Record: " + userScores[indexPath.row].finishTime[0]
            yourScoreCell.secondRecordLabel.text = secondRecord
            yourScoreCell.thirdRecordLabel.text = thirdRecord
        }
        
        return yourScoreCell
    }
    
    
    func setRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(reloadTimeline(refreshControl:)), for: .valueChanged)
        yourResultTableView.addSubview(refreshControl)
    }
    
    @objc func reloadTimeline(refreshControl: UIRefreshControl) {
        refreshControl.beginRefreshing()
        // 更新が早すぎるので2秒遅延させる
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            refreshControl.endRefreshing()
        }
    }
    
    @IBAction func back() {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
