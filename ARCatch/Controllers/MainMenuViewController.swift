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

class MainMenuViewController: UIViewController, ARSessionDelegate, GKGameCenterControllerDelegate {
    
    //MARK: Properties
    let configuration = ARWorldTrackingConfiguration()
    let ball = NodeGenerator().getBall()
    var gameCenterEnabled = Bool()
    
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
        performSegue(withIdentifier: "unwindFromMenuSegueID", sender: nil)
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



