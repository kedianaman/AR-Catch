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
    @IBOutlet weak var scoreTitleLabel: UILabel!
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
                scoreTitleLabel.text = "new best"
                createParticles()
                defaults.set(score, forKey: Identifiers.topScore)
            }
            addScoreAndSubmit(topScore: score)
        } else {
            if (score > 0) {
                scoreTitleLabel.text = "new best"
                createParticles()
                defaults.set(score, forKey: Identifiers.topScore)
                addScoreAndSubmit(topScore: score)
            }
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
        particleEmitter.emitterShape = CAEmitterLayerEmitterShape.line
        particleEmitter.emitterSize = CGSize(width: view.frame.size.width, height: 1)
        
        var emitterCells = [CAEmitterCell]()
        let colors = UIColor.ARCatchConfettiColors()
        for color in colors {
            emitterCells.append(makeEmitterCell(color: color))
        }
        
        particleEmitter.emitterCells = emitterCells
        view.layer.addSublayer(particleEmitter)
    }
    
    func makeEmitterCell(color: UIColor) -> CAEmitterCell {
        let confetti = CAEmitterCell()
        let intensity = 1.0
//        confetti.birthRate = Float(6.0 * intensity)
        confetti.birthRate = 30.0
        confetti.lifetime = Float(14.0 * intensity)
        confetti.lifetimeRange = 0
        confetti.color = color.cgColor
        confetti.velocity = CGFloat(350.0 * intensity)
        confetti.velocityRange = CGFloat(80.0 * intensity)
        confetti.emissionLongitude = CGFloat(Double.pi)
        confetti.emissionRange = CGFloat(Double.pi)
        confetti.spin = CGFloat(3.5 * intensity)
        confetti.spinRange = CGFloat(4.0 * intensity)
        confetti.scaleRange = CGFloat(intensity)
        confetti.scaleSpeed = CGFloat(-0.1 * intensity)
        confetti.contents = UIImage(named: "diamond")?.cgImage
        return confetti
    }
    @IBAction func buttonPressed(_ sender: Any) {
        soundManager.buttonTapped()
    }
    
    
}
