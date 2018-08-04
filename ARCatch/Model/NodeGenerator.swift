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
        ballPhysicsBody.categoryBitMask = BallConstants.categoryBitMask
        ballPhysicsBody.contactTestBitMask = PhonePlaneConstants.categoryBitMask | MissPlaneConstants.categoryBitMask
        ballPhysicsBody.isAffectedByGravity = false
        ballPhysicsBody.angularDamping = 0
        return ballPhysicsBody
    }
    
    
    func getBomb() -> SCNNode {
        let scene = SCNScene(named: "Bomb.scn")!
        let bomb = scene.rootNode.childNode(withName: "Bomb", recursively: true)!
        bomb.position = BombConstants.initialPosition
        bomb.physicsBody = getPhysicsBodyForBomb()
        bomb.name = BombConstants.name
        bomb.addParticleSystem(SCNParticleSystem(named: "Gas.scnp", inDirectory: nil)!)
        
        if let audioSource = SoundManager().litFuseAudioPlayer {
            audioSource.volume = 0.05
            audioSource.isPositional = true
            audioSource.shouldStream = false
            audioSource.loops = true
            audioSource.load()
            let player = SCNAudioPlayer(source: audioSource)
            bomb.addAudioPlayer(player)
            let play = SCNAction.playAudio(audioSource, waitForCompletion: true)
            bomb.runAction(play)
        }
        
        return bomb
    }
    
    private func getPhysicsBodyForBomb() -> SCNPhysicsBody {
        let bombPhysicsBody = SCNPhysicsBody(
            type: .dynamic,
            shape: SCNPhysicsShape(geometry: SCNSphere(radius: BombConstants.physicsRadius))
        )
        bombPhysicsBody.mass = BombConstants.mass
        bombPhysicsBody.damping = BombConstants.damping
        bombPhysicsBody.categoryBitMask = BombConstants.categoryBitMask
        bombPhysicsBody.contactTestBitMask = PhonePlaneConstants.categoryBitMask | MissPlaneConstants.categoryBitMask | BulletConstants.categoryBitMask
        bombPhysicsBody.isAffectedByGravity = false 
        bombPhysicsBody.angularDamping = 0
        return bombPhysicsBody
    }
    
    func getBullet() -> SCNNode {
        let scene = SCNScene(named: "Bullet.scn")!
        let bullet = scene.rootNode.childNode(withName: "bullet", recursively: true)!
        bullet.physicsBody = getPhysicsBodyForBullet()
        bullet.name = BulletConstants.name
        bullet.geometry?.firstMaterial?.shininess = 10
        return bullet
    }
    
    private func getPhysicsBodyForBullet() -> SCNPhysicsBody {
        let bulletPhyiscsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry: SCNSphere(radius: BulletConstants.physicsRadius), options: nil))
        bulletPhyiscsBody.mass = 1
        bulletPhyiscsBody.categoryBitMask = BulletConstants.categoryBitMask
        bulletPhyiscsBody.contactTestBitMask = BombConstants.categoryBitMask
        bulletPhyiscsBody.isAffectedByGravity = false
        bulletPhyiscsBody.angularDamping = 0
        return bulletPhyiscsBody
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
        planePhysicsBody.categoryBitMask = PhonePlaneConstants.categoryBitMask
        planePhysicsBody.contactTestBitMask = BallConstants.categoryBitMask | BombConstants.categoryBitMask
        planePhysicsBody.isAffectedByGravity = false
        planeNode.physicsBody = planePhysicsBody
        return planeNode
    }
    
    func getMissPlane() -> SCNNode {
        // plane behind the phone plane which gets hit if phone misses
        let missPlane = SCNNode()
        missPlane.geometry = SCNPlane(width: MissPlaneConstants.width, height: MissPlaneConstants.height)
//        missPlane.position = SCNVector3(0, 0, 0.5)
        missPlane.position = SCNVector3(0, 0, 1.0)
        missPlane.geometry?.firstMaterial?.diffuse.contents = UIColor(red: 1.0, green: 0, blue: 0, alpha: 0.5)
        missPlane.name = MissPlaneConstants.name
        let missPlanePhysicsBody = SCNPhysicsBody(
            type: .kinematic,
            shape: SCNPhysicsShape(geometry: SCNPlane(width: MissPlaneConstants.width, height: MissPlaneConstants.height))
        )
        missPlanePhysicsBody.categoryBitMask = MissPlaneConstants.categoryBitMask
        missPlanePhysicsBody.contactTestBitMask = BallConstants.categoryBitMask | BombConstants.categoryBitMask
        missPlanePhysicsBody.isAffectedByGravity = false
        missPlane.physicsBody = missPlanePhysicsBody
        return missPlane
    }
}
