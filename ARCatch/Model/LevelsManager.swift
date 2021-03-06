//
//  GameManager.swift
//  ARCatch
//
//  Created by Naman Kedia on 5/22/18.
//  Copyright © 2018 Naman Kedia. All rights reserved.
//

import Foundation
import SceneKit

class LevelsManager {
    
    let nodeGenerator = NodeGenerator()

    func nodeForScore(score: Int) -> SCNNode {
//        if (score % 2 == 0) {
//            return nodeGenerator.getBomb()
//        } else {
//            return nodeGenerator.getBall()
//        }
//        return nodeGenerator.getBomb()
        let level = score / 5
        var probabilityBomb = Double(level) / 20.0
        if (probabilityBomb > (1/4.0)) {
            probabilityBomb = 1/4.0
        }
        // 0 for bomb, 1 for ball
        let randNum = randomNumber(probabilities: [probabilityBomb, (1 - probabilityBomb)])
        if (randNum == 0) {
            return nodeGenerator.getBomb()
        } else {
            return nodeGenerator.getBall()
        }
    }
    
    func torqueForNode(node: SCNNode) -> SCNVector4 {
        if (node.name == "ball") {
          return SCNVector4(rand(0.5, 1.0), rand(0.5, 1.0), rand(0.5, 1.0), rand(0.5, 1.0))
        } else if (node.name == "bomb") {
            return SCNVector4(rand(0.2, 0.5), rand(0.2, 0.5), rand(0.2, 0.5), rand(0.2, 0.5))
        }
        return SCNVector4Zero
    }
    
    
    func forceForScore(score: Int) -> SCNVector3 {
        let level = score / DifficultyConstants.scoreChangeInterval
        var zForce = DifficultyConstants.startZForce + (DifficultyConstants.zForceIncrement * Double(level))
        if (zForce > DifficultyConstants.maxZForce) {
            zForce = DifficultyConstants.maxZForce
        }
        let xForce = xForceFor(zForce: zForce)
        let yForce = yForceFor(zForce: zForce)
        return SCNVector3(xForce, yForce, zForce)
    }
    
    private func xForceFor(zForce: Double) -> Double {
        let timeSquared = ((2 * DifficultyConstants.zDistance) / (zForce/Double(BallConstants.mass)))
        let xForce = (2 * DifficultyConstants.desiredXDistance * Double(BallConstants.mass)) / (timeSquared)
        return Double(rand(Float(xForce), Float(-xForce)))
    }
    
    private func yForceFor(zForce: Double) -> Double {
//        let timeSquared = ((2 * DifficultyConstants.zDistance) / (zForce/Double(BallConstants.mass)))
//        let yForce = (2 * DifficultyConstants.desiredYDistance * Double(BallConstants.mass)) / (timeSquared)
//        return Double(rand(Float(yForce), Float(-yForce)))
        var maxY = Double()
        var minY = Double()
        if (zForce == 30.0) {
            maxY = YForceConstants.max30
            minY = YForceConstants.min30
        } else if (zForce == 35.0) {
            maxY = YForceConstants.max35
            minY = YForceConstants.min35
        } else if (zForce == 40.0) {
            maxY = YForceConstants.max40
            minY = YForceConstants.min40
        } else if (zForce == 45.0) {
            maxY = YForceConstants.max45
            minY = YForceConstants.min45
        } else if (zForce == 50.0) {
            maxY = YForceConstants.max50
            minY = YForceConstants.min50
        } else if (zForce == 55.0) {
            maxY = YForceConstants.max55
            minY = YForceConstants.min55
        } else if (zForce == 60.0) {
            maxY = YForceConstants.max60
            minY = YForceConstants.min60
        } else if (zForce == 65.0) {
            maxY = YForceConstants.max65
            minY = YForceConstants.min65
        } else if (zForce == 70.0) {
            maxY = YForceConstants.max70
            minY = YForceConstants.min70
        } else if (zForce == 75.0) {
            maxY = YForceConstants.max70
            minY = YForceConstants.min70
        } else {
            minY = 0
            maxY = 0
        }
        return Double(rand(Float(maxY), Float(minY)))

    }
    
    private func rand(_ firstNum: Float, _ secondNum: Float) -> Float {
        return Float(arc4random()) / Float(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum)
    }
}

func randomNumber(probabilities: [Double]) -> Int {
    
    // Sum of all probabilities (so that we don't have to require that the sum is 1.0):
    let sum = probabilities.reduce(0, +)
    // Random number in the range 0.0 <= rnd < sum :
    let rnd = sum * Double(arc4random_uniform(UInt32.max)) / Double(UInt32.max)
    // Find the first interval of accumulated probabilities into which `rnd` falls:
    var accum = 0.0
    for (i, p) in probabilities.enumerated() {
        accum += p
        if rnd < accum {
            return i
        }
    }
    // This point might be reached due to floating point inaccuracies:
    return (probabilities.count - 1)
}

