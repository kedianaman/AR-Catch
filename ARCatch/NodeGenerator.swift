//
//  NodeGenerator.swift
//  ARCatch
//
//  Created by Naman Kedia on 5/22/18.
//  Copyright © 2018 Naman Kedia. All rights reserved.
//

import Foundation
import SceneKit

class NodeGenerator {
    
    func getBall() -> SCNNode {
        let scene = SCNScene(named: "Ball.scn")!
        let ball = scene.rootNode.childNode(withName: "sphere", recursively: true)!
        ball.position = BallConstants.initialPosition
        ball.physicsBody = getPhysicsBodyForBall()
        ball.name = BallConstants.name
        return ball
    }
    
    private func getPhysicsBodyForBall() -> SCNPhysicsBody {
        let ballPhysicsBody = SCNPhysicsBody(
            type: .dynamic,
            shape: SCNPhysicsShape(geometry: SCNSphere(radius: BallConstants.physicsRadius))
        )
        ballPhysicsBody.mass = BallConstants.mass
        ballPhysicsBody.damping = BallConstants.damping
        ballPhysicsBody.contactTestBitMask = 1
        ballPhysicsBody.isAffectedByGravity = false
        ballPhysicsBody.angularDamping = 0
        return ballPhysicsBody
    }
    
    
    func getPhonePlane() -> SCNNode {
        // plane behind the phone plane which gets hit if phone misses
        let planeNode = SCNNode()
        planeNode.geometry = SCNPlane(width: PhonePlaneConstants.width, height: PhonePlaneConstants.height)
        planeNode.position = SCNVector3(0, 0, 0)
        planeNode.geometry?.firstMaterial?.diffuse.contents = UIColor(white: 1.0, alpha: 0.5)
        planeNode.name = PhonePlaneConstants.name
        let planePhysicsBody = SCNPhysicsBody(
            type: .kinematic,
            shape: SCNPhysicsShape(geometry: SCNPlane(width: PhonePlaneConstants.width, height: PhonePlaneConstants.height))
        )
        planePhysicsBody.contactTestBitMask = 1
        planePhysicsBody.isAffectedByGravity = false
        planeNode.physicsBody = planePhysicsBody
        return planeNode
    }
    
    func getMissPlane() -> SCNNode {
        // plane behind the phone plane which gets hit if phone misses
        let missPlane = SCNNode()
        missPlane.geometry = SCNPlane(width: MissPlaneConstants.width, height: MissPlaneConstants.height)
        missPlane.position = SCNVector3(0, 0, 0.5)
        missPlane.geometry?.firstMaterial?.diffuse.contents = UIColor(red: 1.0, green: 0, blue: 0, alpha: 0.5)
        missPlane.name = MissPlaneConstants.name
        let missPlanePhysicsBody = SCNPhysicsBody(
            type: .kinematic,
            shape: SCNPhysicsShape(geometry: SCNPlane(width: MissPlaneConstants.width, height: MissPlaneConstants.height))
        )
        missPlanePhysicsBody.contactTestBitMask = 1
        missPlanePhysicsBody.isAffectedByGravity = false
        missPlane.physicsBody = missPlanePhysicsBody
        return missPlane
    }
    
//    @objc func addBat() {
//        let bat = getBat()
//        self.sceneView.scene.rootNode.addChildNode(bat)
//        let x = rand(-2, 2)
//        let y = rand(10, 12)
//        bat.physicsBody?.applyForce(SCNVector3(x: x, y: y, z: 60), at: SCNVector3(0, 1, 0.3), asImpulse: true)
//    }
//
//
//    func getBat() -> SCNNode {
//        let scene = SCNScene(named: "Baseball_Bat.scn")!
//        let ball = scene.rootNode.childNode(withName: "bat", recursively: true)!
//        ball.position = SCNVector3(x: 0, y: 1.5, z: -20)
//        ball.pivot = SCNMatrix4MakeTranslation(0, 15, 0)
//        ball.physicsBody = getPhysicsBodyForBat()
//        ball.name = "bat"
//        return ball
//    }
//
//    func getPhysicsBodyForBat() -> SCNPhysicsBody {
//        let ballPhysicsBody = SCNPhysicsBody(
//            type: .dynamic,
//            shape: SCNPhysicsShape(geometry: SCNCylinder(radius: 0.3, height: 7))
//        )
//        ballPhysicsBody.mass = 3
//        ballPhysicsBody.friction = 2
//        ballPhysicsBody.contactTestBitMask = 1
//        ballPhysicsBody.isAffectedByGravity = true
//        return ballPhysicsBody
//    }
    
}
