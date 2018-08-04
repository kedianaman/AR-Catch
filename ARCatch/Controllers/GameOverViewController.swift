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
    let soundManager = SoundManager()
    
    //MARK: VC Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // because 0 is misaligned in font 
        if (score == 0) {
            scoreLabel.text = "O"
        } else {
            scoreLabel.text = "\(score!)"
        }
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
    
    @IBAction func buttonPressed(_ sender: Any) {
        soundManager.buttonTapped()
    }
    
    
}
