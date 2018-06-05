//
//  PhysicalConstants.swift
//  ARCatch
//
//  Created by Naman Kedia on 5/22/18.
//  Copyright © 2018 Naman Kedia. All rights reserved.
//

import Foundation
import SceneKit


struct DifficultyConstants {
    static let desiredXDistance = 0.4
    static let desiredYDistance = 0.2
    static let zDistance = 20.0
    static let startZForce = 30.0
//    static let startZForce = 70.0

    static let scoreChangeInterval = 5
    static let zForceIncrement = 5.0
    static let maxZForce = 75.0
}

struct BallConstants {
    static let mass: CGFloat = 3.0
    static let physicsRadius: CGFloat = 0.25
    static let damping: CGFloat = 0
    static let initialPosition = SCNVector3(0, 0, -20)
    static let name = "ball"
    static let categoryBitMask = 0x1 << 0
}

struct BombConstants {
    static let mass: CGFloat = 3.0
    static let physicsRadius: CGFloat = 0.2
    static let damping: CGFloat = 0
    static let initialPosition = SCNVector3(0, 0, -20)
    static let name = "bomb"
    static let categoryBitMask = 0x1 << 1
}

struct BulletConstants {
    static let physicsRadius: CGFloat = 0.025
    static let name = "bullet"
    static let categoryBitMask = 0x1 << 2
}

struct PhonePlaneConstants {
    static let width: CGFloat = 0.07
    static let height: CGFloat = 0.143
    static let name = "phonePlane"
    static let categoryBitMask = 0x1 << 3
}

struct MissPlaneConstants {
    static let width: CGFloat = 100.0
    static let height: CGFloat = 100.0
    static let name = "missPlane"
    static let categoryBitMask = 0x1 << 4
}

struct Identifiers {
    static let topScore = "topScore"
    static let leaderboardID = "com.score.arcatch"
}


