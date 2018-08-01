//
//  GameOverViewController.swift
//  ARCatch
//
//  Created by Naman Kedia on 5/24/18.
//  Copyright © 2018 Naman Kedia. All rights reserved.
//

import UIKit
import GameKit

class GameOverViewController: UIViewController {
    
    //MARK: IB Outlets
    @IBOutlet weak var scoreLabel: UILabel!
    
    //MARK: Properties
    var score: Int!
    
    //MARK: VC Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        scoreLabel.text = "\(score!)"
        let defaults = UserDefaults.standard
        if let topScore = defaults.value(forKey: Identifiers.topScore) as? Int {
            if score > topScore {
                defaults.set(score, forKey: Identifiers.topScore)
            }
            addScoreAndSubmit(topScore: score)
        } else {
            defaults.set(score, forKey: Identifiers.topScore)
            addScoreAndSubmit(topScore: score)
        }
    }
    
    //MARK: IB Action
    @IBAction func shareButtonPressed(_ sender: Any) {
        if let myWebsite = NSURL(string: "https://itunes.apple.com/us/app/trojansense/id1361503226?mt=8") {
            let shareText = "I scored \(score!) in Balls & Bombs! Play it too at: "
            let activityVC = UIActivityViewController(activityItems: [shareText, myWebsite], applicationActivities: [])
            self.present(activityVC, animated: true, completion: nil)
        }
    }
    
    //MARK: Helper Functions
    func addScoreAndSubmit(topScore: Int) {
        let bestSpeedInt = GKScore(leaderboardIdentifier: Identifiers.leaderboardID)
        bestSpeedInt.value = Int64(topScore)
        GKScore.report([bestSpeedInt]) { (error) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                print("Best Score submitted to your Leaderboard!")
            }
        }
    }
    
}
