//
//  MainMenuViewController.swift
//  ARCatch
//
//  Created by Naman Kedia on 5/23/18.
//  Copyright © 2018 Naman Kedia. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import GameKit
import StoreKit

class MainMenuViewController: UIViewController, ARSessionDelegate, GKGameCenterControllerDelegate {
    
    //MARK: Properties
    var gameCenterEnabled = Bool()
    var volumeEnabled = true
    
    //MARK: IB Outlets
    @IBOutlet weak var topScoreLabel: UILabel!
    @IBOutlet weak var playNowButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    
    //MARK: View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        authenticateLocalPlayer()
        
    }
    
    //MARK: IB Actions
    @IBAction func playButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "unwindToStartGameSegueID", sender: nil)
    }
    
    @IBAction func heartButtonPressed(_ sender: Any) {
        SKStoreReviewController.requestReview()
    }
  
    @IBAction func volumeButtonPressed(_ sender: UIButton) {
        if (volumeEnabled == true) {
            sender.setImage(#imageLiteral(resourceName: "Volume Off"), for: .normal)
            volumeEnabled = false
        } else {
            sender.setImage(#imageLiteral(resourceName: "Volume On"), for: .normal)
            volumeEnabled = true
        }
    }
    
    @IBAction func leaderboardButtonPressed(_ sender: Any) {
        let gameCenterViewController = GKGameCenterViewController()
        gameCenterViewController.gameCenterDelegate = self
        gameCenterViewController.viewState = .leaderboards
        gameCenterViewController.leaderboardIdentifier = Identifiers.leaderboardID
        present(gameCenterViewController, animated: true, completion: nil)
    }
    
    //MARK: Game Center Delegate
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Game Center
    func authenticateLocalPlayer() {
        let localPlayer: GKLocalPlayer = GKLocalPlayer.localPlayer()
        localPlayer.authenticateHandler = {(ViewController, error) -> Void in
            if((ViewController) != nil) {
                self.present(ViewController!, animated: true, completion: nil)
            } else if (localPlayer.isAuthenticated) {
                self.gameCenterEnabled = true
                localPlayer.loadDefaultLeaderboardIdentifier(completionHandler: { (leaderboardIdentifer, error) in
                    if error != nil {
                        print(error!)
                    } 
                })
            } else {
                self.gameCenterEnabled = false
                print("Local player could not be authenticated!")
                print(error!)
            }
        }
    }
    
    //MARK: Helper Functions
    func setUpView() {
        if let topScore = UserDefaults.standard.value(forKey: Identifiers.topScore) as? Int {
            topScoreLabel.text = "\(topScore)"
        } else {
            topScoreLabel.text = "0"
        }
    }
    
}



