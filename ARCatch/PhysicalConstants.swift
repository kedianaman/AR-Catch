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
    static let startZForce = 50.0
    static let scoreChangeInterval = 5
    static let zForceIncrement = 5.0
    static let maxZForce = 100.0
}

struct BallConstants {
    static let mass: CGFloat = 3.0
    static let physicsRadius: CGFloat = 0.3
    static let damping: CGFloat = 0
    static let initialPosition = SCNVector3(0, 0, -20)
    static let name = "ball"
}

struct PhonePlaneConstants {
    static let width: CGFloat = 0.07
    static let height: CGFloat = 0.143
    static let name = "phonePlane"
}

struct MissPlaneConstants {
    static let width: CGFloat = 10.0
    static let height: CGFloat = 10.0
    static let name = "missPlane"
}
