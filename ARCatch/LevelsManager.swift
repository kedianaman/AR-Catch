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
    
    func rand(_ firstNum: Float, _ secondNum: Float) -> Float {
        return Float(arc4random()) / Float(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum)
    }
}

