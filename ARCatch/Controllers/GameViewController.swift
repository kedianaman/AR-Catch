//
//  ViewController.swift
//  ARCatch
//
//  Created by Naman Kedia on 5/17/18.
//  Copyright © 2018 Naman Kedia. All rights reserved.
//

import UIKit
import ARKit
import AudioToolbox.AudioServices

class GameViewController: UIViewController, SCNPhysicsContactDelegate, ARSessionDelegate {
    
    //MARK: Properties
    let configuration = ARWorldTrackingConfiguration()
    var notificationfeedbackGenerator = UINotificationFeedbackGenerator()
    var heavyFeedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
    
    var selectionFeedbackGenerator = UISelectionFeedbackGenerator()
    var timer = Timer()
    var menuOnScreen = true
    var firstTime = true
    var gameStarted = false
    var bombOnScreen = false
    var gameBall = SCNNode()
    var setUpBall = SCNNode()
    var bullets = [SCNNode]()
    var score = 0 {
        didSet {
            DispatchQueue.main.async {
                self.scoreLabel.text = "\(self.score)"
            }
        }
    }
    var numBallMisses = 0 {
        didSet {
            DispatchQueue.main.async {
                if (self.numBallMisses == 0) {
                    for cross in self.ballMissCrosses {
                        cross.alpha = 0
                    }
                } else {
                    self.ballMissCrosses[self.numBallMisses - 1].alpha = 1
                    self.ballMissCrosses[self.numBallMisses - 1].shake()
                }
            }
        }
    }
    let levelsManager = LevelsManager()
    let nodeGenerator = NodeGenerator()
    
    //MARK: IB Outlets
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var startGameButton: UIButton!
    @IBOutlet weak var crossesBackgroundStackView: UIStackView!
    @IBOutlet var ballMissCrosses: [UIImageView]!
    @IBOutlet var backgroundCrosses: [UIImageView]!
    @IBOutlet weak var yForceStepper: UIStepper!
    @IBOutlet weak var headerBannerView: UIView!
    
    //MARK: View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sceneView.scene.physicsWorld.contactDelegate = self
        //        configuration.isLightEstimationEnabled = true
        self.sceneView.session.run(configuration)
        self.sceneView.autoenablesDefaultLighting = true
        self.sceneView.session.delegate = self
        configuration.isAutoFocusEnabled = false
//        self.sceneView.showsStatistics = true
        //        self.sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin]
        //        addObject()
        addPhonePlane()
        addMissPlane()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if (menuOnScreen == true) {
            menuShowingSetUp()
        } else {
            pregameSetUp()
        }
    }
    
    //MARK: IB Actions
    @IBAction func hitStartButton(_ sender: UIButton) {
        startGameSetUp()
    }
    @IBAction func addBall(_ sender: Any) {
        self.addObject()
    }
    
    // shoots bullets when bomb is on screen
    @IBAction func didTapScreen(_ sender: Any) {
        if (bombOnScreen == true) {
            selectionFeedbackGenerator.prepare()
            selectionFeedbackGenerator.selectionChanged()
            let bullet = nodeGenerator.getBullet()
            bullets.append(bullet)
            let (direction, _) = getUserVector()
            let play = SCNAction.playAudio(SCNAudioSource(fileNamed: "plop.mp3")!, waitForCompletion: true)
            bullet.runAction(play)
            if let phonePlane = self.sceneView.pointOfView?.childNodes.first {
                bullet.position = SCNVector3(0, 0, -0.01)
                phonePlane.addChildNode(bullet)
                bullet.physicsBody?.applyForce(direction, asImpulse: true)
            }
        }
    }
    
    //MARK: Set Up State Functions
    func menuShowingSetUp() {
        performSegue(withIdentifier: "gameToMenuSegueID", sender: nil)
        setUpBall = nodeGenerator.getBomb()
        setUpBall.position = SCNVector3(0, 0.15, -20)
        let rotateBall = SCNAction.rotateBy(x: CGFloat(2 * Double.pi), y: 0, z: 0, duration: 20000.0)
        let rotateForever = SCNAction.repeatForever(rotateBall)
        let moveBall = SCNAction.moveBy(x: 0, y: 0, z: 19, duration: 2.0)
        moveBall.timingMode = .easeIn
        setUpBall.runAction(SCNAction.group([rotateForever, moveBall]))
        sceneView.pointOfView?.addChildNode(setUpBall)
        startGameButton.alpha = 0
        startGameButton.isEnabled = false
        animateStartGameUI(begin: false)
        headerBannerView.alpha = 0
        numBallMisses = 0
    }
    
    func pregameSetUp() {
        startGameButton.alpha = 1
        startGameButton.isEnabled = true
        headerBannerView.alpha = 1
        gameStarted = false
        scoreLabel.alpha = 0
        crossesBackgroundStackView.alpha = 0
        startGameButton.alpha = 1
        startGameButton.isEnabled = true
        score = 0
        numBallMisses = 0
        menuOnScreen = false
        if (setUpBall.parent == nil) {
            addSetUpBall()
        }
    }
    
    func startGameSetUp() {
        self.sceneView.session.setWorldOrigin(relativeTransform: (self.sceneView.pointOfView?.simdTransform)!)
        print(setUpBall.worldPosition)
        gameStarted = true
        scoreLabel.alpha = 1
        crossesBackgroundStackView.alpha = 1
        animateStartGameUI(begin: true)
        startGameButton.alpha = 0
        startGameButton.isEnabled = false
        setUpBall.physicsBody = nil
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.setUpBall.removeFromParentNode()
            self.addObject()
        }
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    func animateStartGameUI(begin: Bool) {
        if (begin == true) {
            for backgroundCross in backgroundCrosses {
                backgroundCross.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                backgroundCross.alpha = 1
            }
            scoreLabel.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            scoreLabel.alpha = 1
        }
       
        var duration = 0.4
        for backgroundCross in backgroundCrosses {
            UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.9, options: .curveEaseInOut, animations: {
                if (begin == true) {
                    backgroundCross.transform = CGAffineTransform.identity
                } else {
                    backgroundCross.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                    backgroundCross.alpha = 0
                }
            }, completion: nil)
            duration = duration + 0.2
        }
        
        
        UIView.animate(withDuration: 0.6, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.9, options: .curveEaseInOut, animations: {
            self.headerBannerView.alpha = 0
            if (begin == true) {
                self.scoreLabel.transform = CGAffineTransform.identity
            } else {
                self.scoreLabel.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
                self.scoreLabel.alpha = 0
            }
            
        }, completion: nil)
    }
    
    func showTutorial() {
    
    }
    
    //MARK: Scene Kit Node Functions
    
    @objc func addObject() {
        let node = levelsManager.nodeForScore(score: score)
        node.physicsBody?.isAffectedByGravity = true
        bombOnScreen = node.name == BombConstants.name
        self.sceneView.scene.rootNode.addChildNode(node)
        let force = levelsManager.forceForScore(score: score)
        node.physicsBody?.applyForce(force, asImpulse: true)
        let torque = levelsManager.torqueForNode(node: node)
        node.physicsBody?.applyTorque(torque, asImpulse: true)
        print(node.worldPosition)
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
    
    func addSetUpBall() {
        
        setUpBall = nodeGenerator.getBall()
        setUpBall.position = SCNVector3(0, 5, -20)
        let rotateBall = SCNAction.rotateBy(x: CGFloat(2 * Double.pi), y: 0, z: 0, duration: 5.0)
        let rotateForever = SCNAction.repeatForever(rotateBall)
        let moveBallDown = SCNAction.moveBy(x: 0, y: -5, z: 0, duration: 0.5)
        moveBallDown.timingMode = .easeOut
        setUpBall.runAction(SCNAction.group([rotateForever, moveBallDown]))
        sceneView.pointOfView?.addChildNode(setUpBall)
        
        //
        //        setUpBall = nodeGenerator.getBall()
        //        setUpBall.position = SCNVector3(0, 0, -20)
        //
        //        setUpBall.runAction(moveBallDown)
        //        sceneView.pointOfView?.addChildNode(setUpBall)
    }
    
    func removeBullets() {
        for bullet in bullets {
            let fadeOut = SCNAction.fadeOut(duration: 0.5)
            bullet.runAction(fadeOut) {
                bullet.removeFromParentNode()
            }
        }
        bullets.removeAll()
    }
    
    //MARK: Helper Calculation Functions
    func rand(_ firstNum: Float, _ secondNum: Float) -> Float {
        return Float(arc4random()) / Float(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum)
    }
    
    func getUserVector() -> (SCNVector3, SCNVector3) { // (direction, position)
        if let frame = self.sceneView.session.currentFrame {
            let mat = SCNMatrix4(frame.camera.transform) // 4x4 transform matrix describing camera in world space
            let dir = SCNVector3(-10 * mat.m31, -10 * mat.m32, -10 * mat.m33) // orientation of camera in world space
            let pos = SCNVector3(mat.m41, mat.m42, mat.m43) // location of camera in world space
            return (dir, pos)
        }
        return (SCNVector3(0, 0, -1), SCNVector3(0, 0, -0.2))
    }
    
    //MARK: AR Session Delegate
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        
        switch camera.trackingState {
        case .limited(let reason):
            switch reason {
            case .excessiveMotion:
                print( "Limited tracking: excessive motion")
            case .insufficientFeatures:
                print("Limited tracking: insufficient details")
            case .initializing:
                print("....initializing")
            case .relocalizing:
                print( "...relocalizing")
            }
        case .notAvailable:
            print("not available")
        case .normal:
            print("normal")
            //                if (gameStarted == false && menuOnScreen == false) {
            //                    addInitialBall()
            //                }
        }
    }
    
    //MARK: Physics World Delegate
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        
        if (gameStarted) {
            
            if (bombOnScreen == true) {
                if (contact.nodeA.name == "bullet" || contact.nodeB.name == "bullet") {
                    if (contact.nodeA.name == BombConstants.name || contact.nodeB.name == BombConstants.name) {
                        if (contact.nodeA.name == BombConstants.name) {
                            contact.nodeA.addParticleSystem(SCNParticleSystem(named: "ExplosionSmall.scnp", inDirectory: nil)!)
                            
                        } else if (contact.nodeB.name == BombConstants.name) {
                            contact.nodeB.addParticleSystem(SCNParticleSystem(named: "ExplosionSmall.scnp", inDirectory: nil)!)
                        }
                        // strong boom vibration
                        let pop = SystemSoundID(1520)
                        AudioServicesPlaySystemSound(pop)
                        contact.nodeA.physicsBody = nil
                        contact.nodeB.physicsBody = nil
                        contact.nodeA.geometry?.firstMaterial?.diffuse.contents = UIColor.clear
                        contact.nodeB.geometry?.firstMaterial?.diffuse.contents = UIColor.clear
                        score = score + 1
                        bombOnScreen = false
                        self.removeBullets()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            contact.nodeB.removeFromParentNode()
                            contact.nodeA.removeFromParentNode()
                            self.addObject()
                        }
                        return
                    }
                }
            }
            
            // successful collisison with phone
            if (contact.nodeA.name == PhonePlaneConstants.name || contact.nodeB.name == PhonePlaneConstants.name) {
                // collision with ball
                if (contact.nodeA.name == BallConstants.name || contact.nodeB.name == BallConstants.name) {
                    DispatchQueue.main.async {
                        self.heavyFeedbackGenerator.prepare()
                        self.heavyFeedbackGenerator.impactOccurred()
                    }
                    score = score + 1
                    let caughtSound = SCNAction.playAudio(SCNAudioSource(named: "caughtball.mp3")!, waitForCompletion: true)
                    contact.nodeA.runAction(caughtSound)
                    print("did catch ball")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        self.addObject()
                    }
                } else {
                    let vibrate = SystemSoundID(kSystemSoundID_Vibrate)
                    AudioServicesPlaySystemSound(vibrate)
                    // collision with bomb -> explosion
                    if (contact.nodeA.name == BombConstants.name) {
                        contact.nodeB.addParticleSystem(SCNParticleSystem(named: "Explosion.scnp", inDirectory: nil)!)
                    } else if (contact.nodeB.name == BombConstants.name) {
                        contact.nodeA.addParticleSystem(SCNParticleSystem(named: "Explosion.scnp", inDirectory: nil)!)
                    }
                    bombOnScreen = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self.performSegue(withIdentifier: "GameOverSegue", sender: nil)
                    }
                }
                
            } else if (contact.nodeA.name == MissPlaneConstants.name || contact.nodeB.name == MissPlaneConstants.name) {
                let missSound = SCNAction.playAudio(SCNAudioSource(named: "Whoosh.mp3")!, waitForCompletion: true)
                contact.nodeA.runAction(missSound)
                print("did miss ball")
                if (contact.nodeA.name == BallConstants.name || contact.nodeB.name == BallConstants.name) {
                    numBallMisses = numBallMisses + 1
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
                    if (self.numBallMisses == 3) {
                        self.performSegue(withIdentifier: "GameOverSegue", sender: nil)
                    } else {
                        self.addObject()
                    }
                }
                
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
            self.removeBullets()
        }
    }
    
    //MARK: Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
            if (node.name == "ball" || node.name == "bomb") {
                node.removeFromParentNode()
            }
        }
        if (segue.identifier == "GameOverSegue") {
            if let gameOverVC = segue.destination as? GameOverViewController {
                gameOverVC.score = score
                //                self.addSetUpBall()
            }
        }
    }
    
    @IBAction func unwindToGame(segue:UIStoryboardSegue) {
        menuOnScreen = true
        self.pregameSetUp()
    }
    
    @IBAction func unwindFromMenu(segue:UIStoryboardSegue) {
        let moveBall = SCNAction.move(to: SCNVector3(0, 0, -20), duration: 1.0)
        moveBall.timingMode = .easeInEaseOut
        setUpBall.runAction(moveBall)
        self.pregameSetUp()
        
    }
    
    @IBAction func unwindToGoToMenu(segue:UIStoryboardSegue) {
        // fix animation 
        //        self.presentedViewController?.dismiss(animated: false, completion: nil)
        
        menuOnScreen = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.menuShowingSetUp()
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
        testPlanePhyicsBody.categoryBitMask = 0x1 << 5
        testPlanePhyicsBody.contactTestBitMask = BallConstants.categoryBitMask
        testPlanePhyicsBody.isAffectedByGravity = false
        testPlane.physicsBody = testPlanePhyicsBody
        sceneView.scene.rootNode.addChildNode(testPlane)
    }
    
}

// function to shake cross
extension UIView {
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        animation.duration = 0.4
        animation.values = [-5.0, 5.0, -4.0, 4.0, -3.0, 3.0, -2, 2.0, 0.0 ]
        layer.add(animation, forKey: "shake")
    }
    
}

