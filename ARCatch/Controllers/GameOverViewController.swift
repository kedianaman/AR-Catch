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
        createParticles()
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
    
    func createParticles() {
        let particleEmitter = CAEmitterLayer()
        
        particleEmitter.emitterPosition = CGPoint(x: view.center.x, y: -96)
        particleEmitter.emitterShape = kCAEmitterLayerLine
        particleEmitter.emitterSize = CGSize(width: view.frame.size.width, height: 1)
        
        let red = makeEmitterCell(color: UIColor.red)
        let green = makeEmitterCell(color: UIColor.green)
        let blue = makeEmitterCell(color: UIColor.blue)
        
        particleEmitter.emitterCells = [red, green, blue]
        
        view.layer.addSublayer(particleEmitter)
    }
    
    func makeEmitterCell(color: UIColor) -> CAEmitterCell {
        let cell = CAEmitterCell()
        cell.birthRate = 10
        cell.lifetime = 7.0
        cell.lifetimeRange = 0
        cell.color = color.cgColor
        cell.velocity = 200
        cell.velocityRange = 50
        cell.emissionLongitude = CGFloat.pi
        cell.emissionRange = CGFloat.pi / 4
        cell.spin = 2
        cell.spinRange = 3
        cell.scaleRange = 0.5
        cell.scaleSpeed = -0.05
        
        cell.contents = UIImage(named: "confetti")?.cgImage
        return cell
    }
    @IBAction func buttonPressed(_ sender: Any) {
        soundManager.buttonTapped()
    }
    
    
}
