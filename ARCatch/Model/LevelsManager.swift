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
        if (score % 5 == 0) {
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
        print ("level: \(level), zForce: \(zForce)")
        return SCNVector3(xForce, yForce, zForce)
    }
    
    private func xForceFor(zForce: Double) -> Double {
        let timeSquared = ((2 * DifficultyConstants.zDistance) / (zForce/Double(BallConstants.mass)))
        let xForce = (2 * DifficultyConstants.desiredXDistance * Double(BallConstants.mass)) / (timeSquared)
        print("xForce: \(xForce)")
        return Double(rand(Float(xForce), Float(-xForce)))
    }
    
    private func yForceFor(zForce: Double) -> Double {
        let timeSquared = ((2 * DifficultyConstants.zDistance) / (zForce/Double(BallConstants.mass)))
        let yForce = (2 * DifficultyConstants.desiredYDistance * Double(BallConstants.mass)) / (timeSquared)
        print("yForce: \(yForce)")
        return Double(rand(Float(yForce), Float(-yForce)))
    }
    
    private func rand(_ firstNum: Float, _ secondNum: Float) -> Float {
        return Float(arc4random()) / Float(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum)
    }
}

