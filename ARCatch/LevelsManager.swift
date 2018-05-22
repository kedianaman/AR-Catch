//
//  GameManager.swift
//  ARCatch
//
//  Created by Naman Kedia on 5/22/18.
//  Copyright © 2018 Naman Kedia. All rights reserved.
//

import Foundation

class LevelsManager {

    init() {
        print(xForceFor(zForce: 60))
    }
    
    func xForceFor(zForce: Double) -> Double {
        let timeSquared = ((2 * PhysicalConstants.zDistance) / (zForce/Double(BallConstants.mass)))
        let xForce = (2 * PhysicalConstants.desiredXDistance * Double(BallConstants.mass)) / (timeSquared)
        return xForce
    }
}

