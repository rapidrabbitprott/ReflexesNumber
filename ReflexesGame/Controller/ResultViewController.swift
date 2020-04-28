//
//  ResultViewController.swift
//  ReflexesGame
//
//  Created by 森川正崇 on 2020/01/12.
//  Copyright © 2020 morikawamasataka. All rights reserved.
//

import UIKit
import Firebase
import PKHUD
class ResultViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,YourScoreTableViewCellDelegate {
    
    var passedFinishTime: String = ""
    var passedCalcType: [String] = []
    var passedConvertedCalcType: String = ""
    var passedLevel: Int = 0
    var finishTimeArray: [String] = []
    var digitsArray: [String] = []
    var kindArray: [String] = []
    var calctypeAndDigits: String = ""
    var countNumber: Int = 0
    var score = [Score]()
    var user = [User]()
    var arrayForIn = [Any]()
    @IBOutlet var resultTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //引張って更新
        setRefreshControl()
        loadRaking()
        countScores()
        //データ・ソースメソッドをこのファイル内で処理する
        resultTableView.dataSource = self
        //このセルが選択された時に処理を実行する。
        resultTableView.delegate = self
        //TableViewの不要な線を消す
        resultTableView.tableFooterView = UIView()
        //                TableViewの高さを動的に決める
        resultTableView.rowHeight = UITableView.automaticDimension
        //カスタムセルの登録(TableView上のcellの名前は関係ない！)
        let nib1 = UINib(nibName: "YourScoreTableViewCell", bundle: Bundle.main)
        resultTableView.register(nib1, forCellReuseIdentifier: "ScoreCell")
        let nib2 = UINib(nibName: "RankingTableViewCell", bundle: Bundle.main)
        resultTableView.register(nib2, forCellReuseIdentifier: "RankingCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        resultTableView.reloadData()
    }
    //表示するCellの種類
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    //tableviewに表示するデータの個数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return self.countNumber
        }
    }
    
    //tableviewに表示するデータの内容
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            //表示するために再利用するViewController上のcell
            let scoreCell = tableView.dequeueReusableCell(withIdentifier: "ScoreCell") as! YourScoreTableViewCell
            scoreCell.delegate = self
            scoreCell.userTimeLabel.text = passedFinishTime
            return scoreCell
        } else {
            let rankingCell = tableView.dequeueReusableCell(withIdentifier: "RankingCell") as! RankingTableViewCell
            Firestore.firestore().collection("users").document(score[indexPath.row].objectId).getDocument(completion: { (snap, error) in
                let userName = snap?.data()!["userName"]
                rankingCell.userNameLabel.text = userName as! String
            })
            rankingCell.userTimeLabel.text = score[indexPath.row].finishTime
            rankingCell.rankLabel.text = String(indexPath.row + 1)
            if score[indexPath.row].objectId == Auth.auth().currentUser?.uid {
                rankingCell.rankLabel.textColor = UIColor.red
            }
            return rankingCell
        }
        
    }
    
    func returnHome(tableViewCell: UITableViewCell, button: UIButton) {
        // ①storyboardのインスタンス取得
        let storyboard: UIStoryboard = self.storyboard!
        // ②遷移先ViewControllerのインスタンス取得
        let nextView = storyboard.instantiateViewController(withIdentifier: "homeStoryboard") as! StartViewController
        // ③画面遷移
        self.present(nextView, animated: true, completion: nil)
    }
    
    func retry(tableViewCell: UITableViewCell, button: UIButton) {
        // ①storyboardのインスタンス取得
        let storyboard: UIStoryboard = self.storyboard!
        // ②遷移先ViewControllerのインスタンス取得
        let nextView = storyboard.instantiateViewController(withIdentifier: "playStoryboard") as! PlayViewController
        
        // ③遷移先に渡す値
        nextView.passedConvertCalcType = passedConvertedCalcType
        nextView.passedCalcType = passedCalcType
        nextView.passedLevel = passedLevel
        nextView.loadView()
        nextView.viewDidLoad()
        self.present(nextView, animated: true, completion: nil)
    }
    
    func loadRaking() {
        self.score = [Score]()
        Firestore.firestore().collection(calctypeAndDigits).order(by: "finishTime").getDocuments { (snaps, error) in
            for result in snaps!.documents {
                let finishTime = result.data()["finishTime"] as! String
                let objectId = result.data()["userId"] as! String
                let calcType = result.data()["calcType"] as! [String]
                let digits = result.data()["digits"] as! Int
                let scoreset = Score(objectId: objectId, finishTime: finishTime, calcType: calcType, digits: digits)
                self.score.append(scoreset)
                // 投稿のデータが揃ったらTableViewをリロード
                self.resultTableView.reloadData()
                
            }
        }
    }
    
    func countScores() {
        Firestore.firestore().collection(calctypeAndDigits).document("scoreCount").getDocument { (snap, error) in
            self.countNumber = snap?.data()!["scoreCount"] as! Int
        }
    }
    
    func setRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(reloadTimeline(refreshControl:)), for: .valueChanged)
        resultTableView.addSubview(refreshControl)
    }
    
    @objc func reloadTimeline(refreshControl: UIRefreshControl) {
        refreshControl.beginRefreshing()
        // 更新が早すぎるので2秒遅延させる
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            refreshControl.endRefreshing()
        }
    }
}
