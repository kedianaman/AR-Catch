//
//  ViewController.swift
//  ARCatch
//
//  Created by Naman Kedia on 5/17/18.
//  Copyright © 2018 Naman Kedia. All rights reserved.
//

import UIKit
import ARKit

class GameViewController: UIViewController, SCNPhysicsContactDelegate {
    
    
    //MARK: Properties
    let configuration = ARWorldTrackingConfiguration()
    var notificationfeedbackGenerator = UINotificationFeedbackGenerator()
    var feedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
    var timer = Timer()
    var score = 0 {
        didSet {
            DispatchQueue.main.async {
                self.scoreLabel.text = "\(self.score)"
            }
        }
    }
    let levelsManager = LevelsManager()
    let nodeGenerator = NodeGenerator()

    //MARK: IB Outlets
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var scoreLabel: UILabel!
    
    //MARK: View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        score = 0
        self.sceneView.scene.physicsWorld.contactDelegate = self
        self.sceneView.session.run(configuration)
        self.sceneView.autoenablesDefaultLighting = true
        self.sceneView.debugOptions = [SCNDebugOptions.showPhysicsShapes, SCNDebugOptions.showPhysicsFields]
         timer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(GameViewController.addObject), userInfo: nil, repeats: true)
//        addObject()
        addPhonePlane()
        addMissPlane()
//        addBomb()
//        addTestingPlane()
    }
    
    //MARK: Helper functions
    @objc func addObject() {
        let node = levelsManager.nodeForScore(score: score)
        self.sceneView.scene.rootNode.addChildNode(node)
        let force = levelsManager.forceForScore(score: score)
        node.physicsBody?.applyForce(force, asImpulse: true)
        let torque = levelsManager.torqueForNode(node: node)
        node.physicsBody?.applyTorque(torque, asImpulse: true)
//        ball.physicsBody?.applyForce(SCNVector3(x: 1.4, y: 8 , z: 70), asImpulse: true)
//        ball.physicsBody?.applyTorque(SCNVector4(rand(0.2, 0.5), rand(0.2, 0.5), rand(0.2, 0.5), rand(0.2, 0.5)), asImpulse: true)
//        node.physicsBody?.applyTorque(SCNVector4(rand(0.5, 1.0), rand(0.5, 1.0), rand(0.5, 1.0), rand(0.5, 1.0)), asImpulse: true)
    }
    
    func addPhonePlane() {
        // plane behind the phone plane which gets hit if phone misses
        let planeNode = nodeGenerator.getPhonePlane()
        sceneView.pointOfView?.addChildNode(planeNode)
    }

    func addMissPlane() {
        // plane behind the phone plane which gets hit if phone misses
        let missPlane = nodeGenerator.getMissPlane()
        sceneView.pointOfView?.addChildNode(missPlane)
    }
    
    func rand(_ firstNum: Float, _ secondNum: Float) -> Float {
        return Float(arc4random()) / Float(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum)
    }

    
    //MARK: Physics World Delegate
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        // FIX: Prevent planes from colliding with each other
//        if ((contact.nodeA.name == "testPlane" && contact.nodeB.name == BallConstants.name) || (contact.nodeA.name == BallConstants.name && contact.nodeB.name == "testPlane") ) {
//            print(contact.contactPoint)
//        }
        
        // ignore any collisisons other than with ball and bomb
        if ((contact.nodeA.name != BallConstants.name && contact.nodeB.name != BallConstants.name) && (contact.nodeA.name != BombConstants.name && contact.nodeB.name != BombConstants.name)) {
            return
        }
        
        // successful collisison with phone
        if (contact.nodeA.name == PhonePlaneConstants.name || contact.nodeB.name == PhonePlaneConstants.name) {
            // collision with ball
            if (contact.nodeA.name == BallConstants.name || contact.nodeB.name == BallConstants.name) {
                DispatchQueue.main.async {
                    self.notificationfeedbackGenerator.prepare()
                    self.notificationfeedbackGenerator.notificationOccurred(.success)
                }
                score = score + 1
                let caughtSound = SCNAction.playAudio(SCNAudioSource(named: "caughtball.mp3")!, waitForCompletion: true)
                contact.nodeA.runAction(caughtSound)
                print("did catch ball")
            } else {
                DispatchQueue.main.async {
                    self.notificationfeedbackGenerator.prepare()
                    self.notificationfeedbackGenerator.notificationOccurred(.error)
                }
                // collision with bomb -> explosion
                if (contact.nodeA.name == BombConstants.name) {
                    contact.nodeB.addParticleSystem(SCNParticleSystem(named: "Explosion.scnp", inDirectory: nil)!)
                } else if (contact.nodeB.name == BombConstants.name) {
                    contact.nodeA.addParticleSystem(SCNParticleSystem(named: "Explosion.scnp", inDirectory: nil)!)
                }
                // GAME OVER
                score = score + 1
            }
            
        } else if (contact.nodeA.name == MissPlaneConstants.name || contact.nodeB.name == MissPlaneConstants.name) {
//            score = 0
            let missSound = SCNAction.playAudio(SCNAudioSource(named: "Whoosh.mp3")!, waitForCompletion: true)
            contact.nodeA.runAction(missSound)
            print("did miss ball")
        }
        
        if (contact.nodeA.name == BallConstants.name) {
            contact.nodeA.removeFromParentNode()
        } else if (contact.nodeB.name == BallConstants.name) {
            contact.nodeB.removeFromParentNode()
        }
        
        
        if (contact.nodeA.name == BombConstants.name) {
            contact.nodeA.removeFromParentNode()
        } else if (contact.nodeB.name == BombConstants.name) {
            contact.nodeB.removeFromParentNode()
        }
    }
    
    // Scrap later functions
    
    func addTestingPlane() {
        let testPlane = SCNNode()
        testPlane.geometry = SCNPlane(width: 10, height: 10)
        testPlane.position = SCNVector3(0, 0, 0)
        testPlane.geometry?.firstMaterial?.diffuse.contents = UIColor(red: 1.0, green: 0, blue: 0, alpha: 0.5)
        testPlane.name = "testPlane"
        let testPlanePhyicsBody = SCNPhysicsBody(
            type: .kinematic,
            shape: SCNPhysicsShape(geometry: SCNPlane(width: 100, height: 100))
        )
        testPlanePhyicsBody.contactTestBitMask = 1
        testPlanePhyicsBody.isAffectedByGravity = false
        testPlane.physicsBody = testPlanePhyicsBody
        sceneView.scene.rootNode.addChildNode(testPlane)
    }
    

    
    

}

