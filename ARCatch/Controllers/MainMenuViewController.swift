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
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var topScoreLabel: UILabel!
    
    //MARK: View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.session.run(configuration)
        sceneView.autoenablesDefaultLighting = true
        self.sceneView.session.delegate = self
        authenticateLocalPlayer()
        setUpView()
    }
    
    //MARK: Helper Functions
    func setUpView() {
        ball.position = SCNVector3(0, 0, -1)
        let rotateBall = SCNAction.rotateBy(x: CGFloat(2 * Double.pi), y: 0, z: 0, duration: 3.0)
        let rotateForever = SCNAction.repeatForever(rotateBall)
        ball.runAction(rotateForever)
        sceneView.pointOfView?.addChildNode(ball)
        if let topScore = UserDefaults.standard.value(forKey: Identifiers.topScore) as? Int {
            topScoreLabel.text = "\(topScore)"
        } else {
            topScoreLabel.text = "0"
        }
    }
    
    //MARK: IB Actions
    @IBAction func playButtonPressed(_ sender: Any) {
        let moveToPosition = SCNAction.move(to: SCNVector3(0,3,0), duration: 2.0)
        moveToPosition.timingMode = .easeOut
        ball.runAction(moveToPosition) {
            print("completed")
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "MenuToGameSegueIdentifer", sender: nil)
            }
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
   
    
}



