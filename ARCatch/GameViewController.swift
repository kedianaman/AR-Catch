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

    //MARK: IB Outlets
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var scoreLabel: UILabel!
    
    //MARK: View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sceneView.scene.physicsWorld.contactDelegate = self
        self.sceneView.session.run(configuration)
        self.sceneView.autoenablesDefaultLighting = true
        self.sceneView.debugOptions = [SCNDebugOptions.showPhysicsShapes, SCNDebugOptions.showPhysicsFields]
         timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(GameViewController.addBall), userInfo: nil, repeats: true)
        addBall()
        addPhonePlane()
        addMissPlane()
    }
    
    //MARK: Helper functions
    @objc func addBall() {
        let ball = getBall()
        self.sceneView.scene.rootNode.addChildNode(ball)
        let x = rand(-2, 2)
        let y = rand(10, 12)
        ball.physicsBody?.applyForce(SCNVector3(x: x, y: y, z: 60), asImpulse: true)
        ball.physicsBody?.applyTorque(SCNVector4(rand(0.5, 1.5), rand(0.5, 1.5), rand(0.5, 1.5), rand(0.5, 1.5)), asImpulse: true)
    }
    
    func getBall() -> SCNNode {
        let scene = SCNScene(named: "Ball.scn")!
        let ball = scene.rootNode.childNode(withName: "sphere", recursively: true)!
        ball.position = SCNVector3(x: 0, y: 1.5, z: -20)
        ball.physicsBody = getPhysicsBodyForBall()
        ball.name = "ball"
        return ball
    }
    
    func getPhysicsBodyForBall() -> SCNPhysicsBody {
        let ballPhysicsBody = SCNPhysicsBody(
            type: .dynamic,
            shape: SCNPhysicsShape(geometry: SCNSphere(radius: 0.35))
        )
        ballPhysicsBody.mass = 3
        ballPhysicsBody.friction = 2
        ballPhysicsBody.contactTestBitMask = 1
        ballPhysicsBody.isAffectedByGravity = true
        return ballPhysicsBody
    }
    
    @objc func addBat() {
        let bat = getBat()
        self.sceneView.scene.rootNode.addChildNode(bat)
        let x = rand(-2, 2)
        let y = rand(10, 12)
        bat.physicsBody?.applyForce(SCNVector3(x: x, y: y, z: 60), at: SCNVector3(0, 1, 0.3), asImpulse: true)
    }
    
    
    func getBat() -> SCNNode {
        let scene = SCNScene(named: "Baseball_Bat.scn")!
        let ball = scene.rootNode.childNode(withName: "bat", recursively: true)!
        ball.position = SCNVector3(x: 0, y: 1.5, z: -20)
        ball.pivot = SCNMatrix4MakeTranslation(0, 15, 0)
        ball.physicsBody = getPhysicsBodyForBat()
        ball.name = "bat"
        return ball
    }
    
    func getPhysicsBodyForBat() -> SCNPhysicsBody {
        let ballPhysicsBody = SCNPhysicsBody(
            type: .dynamic,
            shape: SCNPhysicsShape(geometry: SCNCylinder(radius: 0.3, height: 7))
        )
        ballPhysicsBody.mass = 3
        ballPhysicsBody.friction = 2
        ballPhysicsBody.contactTestBitMask = 1
        ballPhysicsBody.isAffectedByGravity = true
        return ballPhysicsBody
    }
    
    func addPhonePlane() {
        // plane behind the phone plane which gets hit if phone misses
        let planeNode = SCNNode()
        planeNode.geometry = SCNPlane(width: 0.1, height: 0.2)
        planeNode.position = SCNVector3(0, 0, 0)
        planeNode.geometry?.firstMaterial?.diffuse.contents = UIColor(white: 1.0, alpha: 0.5)
        planeNode.name = "phonePlane"
        let planePhysicsBody = SCNPhysicsBody(
            type: .kinematic,
            shape: SCNPhysicsShape(geometry: SCNPlane(width: 0.07, height: 0.143))
        )
        planePhysicsBody.contactTestBitMask = 1
        planePhysicsBody.isAffectedByGravity = false
        planeNode.physicsBody = planePhysicsBody
        sceneView.pointOfView?.addChildNode(planeNode)
    }
    
    func addMissPlane() {
        // plane behind the phone plane which gets hit if phone misses
        let missPlane = SCNNode()
        missPlane.geometry = SCNPlane(width: 1, height: 1)
        missPlane.position = SCNVector3(0, 0, 0.5)
        missPlane.geometry?.firstMaterial?.diffuse.contents = UIColor(red: 1.0, green: 0, blue: 0, alpha: 0.5)
        missPlane.name = "missPlane"
        let missPlanePhysicsBody = SCNPhysicsBody(
            type: .kinematic,
            shape: SCNPhysicsShape(geometry: SCNPlane(width: 10, height: 10))
        )
        missPlanePhysicsBody.contactTestBitMask = 1
        missPlanePhysicsBody.isAffectedByGravity = false
        missPlane.physicsBody = missPlanePhysicsBody
        sceneView.pointOfView?.addChildNode(missPlane)
    }
    
    func rand(_ firstNum: Float, _ secondNum: Float) -> Float {
        return Float(arc4random()) / Float(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum)
    }
    
    //MARK: Physics World Delegate
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        // FIX: Prevent planes from colliding with each other
        if (contact.nodeA.name == "bat" || contact.nodeB.name == "bat") {
            DispatchQueue.main.async {
                self.notificationfeedbackGenerator.prepare()
                self.notificationfeedbackGenerator.notificationOccurred(.error)
            }
            
            if (contact.nodeA.name == "bat") {
                contact.nodeA.removeFromParentNode()
            } else if (contact.nodeB.name == "bat") {
                contact.nodeB.removeFromParentNode()
            }
            print("hit bat")
            return
        }
        if (contact.nodeA.name != "ball" && contact.nodeB.name != "ball") {
            return
        }
        
        if (contact.nodeA.name == "phonePlane" || contact.nodeB.name == "phonePlane") {
            DispatchQueue.main.async {
                self.notificationfeedbackGenerator.prepare()
                self.notificationfeedbackGenerator.notificationOccurred(.success)
            }
            score = score + 1
            let caughtSound = SCNAction.playAudio(SCNAudioSource(named: "caughtball.mp3")!, waitForCompletion: true)
            contact.nodeA.runAction(caughtSound)
            print("did catch ball")
        } else if (contact.nodeA.name == "missPlane" || contact.nodeB.name == "missPlane") {
            score = 0
            let missSound = SCNAction.playAudio(SCNAudioSource(named: "Whoosh.mp3")!, waitForCompletion: true)
            contact.nodeA.runAction(missSound)
            print("did miss ball")
        }
        
        if (contact.nodeA.name == "ball") {
            contact.nodeA.removeFromParentNode()
        } else if (contact.nodeB.name == "ball") {
            contact.nodeB.removeFromParentNode()
        }
        
       
    }

    
    

}

