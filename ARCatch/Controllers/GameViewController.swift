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

class GameViewController: UIViewController, SCNPhysicsContactDelegate, ARSCNViewDelegate, ARSessionDelegate, TutorialViewControllerDelegate {
    
    //MARK: Properties
    let configuration = ARWorldTrackingConfiguration()
    var notificationfeedbackGenerator = UINotificationFeedbackGenerator()
    var heavyFeedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
    
    var selectionFeedbackGenerator = UISelectionFeedbackGenerator()
    var timer = Timer()
    var initialLaunch = true
    var menuOnScreen = true
    var gameStarted = false
    var bombOnScreen = false
    var tutorialInProgress = Bool()
    var gameBall = SCNNode()
    var setUpBall = SCNNode()
    var tutorialBomb = SCNNode()
    var missPlane = SCNNode()
    var bullets = [SCNNode]()
    var lastUpdateTime: TimeInterval = 0
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
                    if (self.numBallMisses <= 3) {
                        self.ballMissCrosses[self.numBallMisses - 1].alpha = 1
                        self.ballMissCrosses[self.numBallMisses - 1].shake()
                    }
                }
            }
        }
    }
    let levelsManager = LevelsManager()
    let nodeGenerator = NodeGenerator()
    let soundManager = SoundManager()
    
    //MARK: IB Outlets
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var startGameButton: UIButton!
    @IBOutlet weak var crossesBackgroundStackView: UIStackView!
    @IBOutlet var ballMissCrosses: [UIImageView]!
    @IBOutlet var backgroundCrosses: [UIImageView]!
    @IBOutlet weak var headerBannerView: UIView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var goHomeButton: UIButton!

    //MARK: View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sceneView.scene.physicsWorld.contactDelegate = self
        self.sceneView.session.run(configuration)
        self.sceneView.autoenablesDefaultLighting = true
        self.sceneView.session.delegate = self
        configuration.isAutoFocusEnabled = false
//        self.sceneView.showsStatistics = true
        self.sceneView.delegate = self
        //        self.sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin]
        //        addObject()
        addPhonePlane()
        addMissPlane()
        loadingView.alpha = 1
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override var prefersStatusBarHidden: Bool {
        return true 
    }
    
    //MARK: IB Actions
    @IBAction func hitStartButton(_ sender: UIButton) {
        soundManager.buttonTapped()
        startGameSetUp()
    }
    @IBAction func addBall(_ sender: Any) {
        self.addObject()
    }
    
    // shoots bullets when bomb is on screen
    @IBAction func didTapScreen(_ sender: Any) {
        if (bombOnScreen == true) {
            shootBullet()
        }
    }
    @IBAction func goHomeFromPregame(_ sender: Any) {
        soundManager.buttonTapped()
        menuShowingSetUp()
    }
    
    //MARK: Set Up State Functions
    
    // Set up menu
    func menuShowingSetUp() {
        performSegue(withIdentifier: "gameToMenuSegueID", sender: nil)
        if (setUpBall.name != BallConstants.name) {
            setUpBall = nodeGenerator.getBall()
            setUpBall.position = SCNVector3(0, 0, -20)
            let rotateBall = SCNAction.rotateBy(x: CGFloat(2 * Double.pi), y: 0, z: 0, duration: 5.0)
            let rotateForever = SCNAction.repeatForever(rotateBall)
            setUpBall.runAction(rotateForever)
        }
        let moveBall = SCNAction.move(to: SCNVector3(0, 0.15, -1), duration: 2.0)
        moveBall.timingMode = .easeOut
        setUpBall.runAction(moveBall)
        sceneView.pointOfView?.addChildNode(setUpBall)
        UIView.animate(withDuration: 1.0) {
            self.startGameButton.alpha = 0
        }
//        startGameButton.alpha = 0
        startGameButton.isEnabled = false
        animateStartGameUI(begin: false)
        headerBannerView.alpha = 0
        numBallMisses = 0
        goHomeButton.alpha = 0
        goHomeButton.isEnabled = false
    }
    
    // Set up view to let user select ball position
    func pregameSetUp() {
        startGameButton.alpha = 1
        startGameButton.isEnabled = true
        headerBannerView.alpha = 1
        goHomeButton.alpha = 1
        goHomeButton.isEnabled = true
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
    
    // Start the game
    func startGameSetUp() {
        self.sceneView.session.setWorldOrigin(relativeTransform: (self.sceneView.pointOfView?.simdTransform)!)
        gameStarted = true
        scoreLabel.alpha = 1
        crossesBackgroundStackView.alpha = 1
        animateStartGameUI(begin: true)
        startGameButton.alpha = 0
        startGameButton.isEnabled = false
        goHomeButton.alpha = 0
         goHomeButton.isEnabled = false
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
        // show tutorial view controller and move ball accordingly
        tutorialInProgress = true
        performSegue(withIdentifier: "gameToTutorialSegueID", sender: nil)
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
    }
    
    func addPhonePlane() {
        // plane behind the phone plane which gets hit if phone misses
        let planeNode = nodeGenerator.getPhonePlane()
        sceneView.pointOfView?.addChildNode(planeNode)
    }
    
    func addMissPlane() {
        // plane behind the phone plane which gets hit if phone misses
        missPlane = nodeGenerator.getMissPlane()
        sceneView.pointOfView?.addChildNode(missPlane)
    }
    
    func updateMissPlane(multipler: Double) {
        if (multipler == 1) {
            missPlane.position = SCNVector3(0, 0, 0.5)
        } else {
            missPlane.position = SCNVector3(0, 0, 1.0)
        }
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
    }
    
    func shootBullet() {
        selectionFeedbackGenerator.prepare()
        selectionFeedbackGenerator.selectionChanged()
        let bullet = nodeGenerator.getBullet()
        bullets.append(bullet)
        let (direction, _) = getUserVector()
        if let plopSound = soundManager.plopSound {
            let play = SCNAction.playAudio(plopSound, waitForCompletion: true)
            bullet.runAction(play)
        }
        if let phonePlane = self.sceneView.pointOfView?.childNodes.first {
            bullet.position = SCNVector3(0, 0, -0.01)
            phonePlane.addChildNode(bullet)
            bullet.physicsBody?.applyForce(direction, asImpulse: true)
        }
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
    
    //MARK: Tutorial VC Delegate
    
    // moves ball towards screen and brings down bomb
    func replaceBallWithBomb() {
        let moveSetUpBall = SCNAction.moveBy(x: 0, y: 0, z: 2, duration: 1.0)
        moveSetUpBall.timingMode = .easeIn
        setUpBall.runAction(moveSetUpBall) {
            self.setUpBall.removeFromParentNode()
        }
    }
    
    // simply shoots the bomb to explode it
    func removeBomb() {
        shootBullet()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.tutorialBomb.removeFromParentNode()
        }
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
            case .initializing:
                print("....initializing")
            default:
                if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized {
                    if (initialLaunch) {
                        loadingView.alpha = 0
                        menuShowingSetUp()
                        initialLaunch = false
                    }
                }
            }
        case .notAvailable:
            print("not available")
        case .normal:
            if (initialLaunch) {
                loadingView.alpha = 0
                menuShowingSetUp()
                initialLaunch = false
            }
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        performSegue(withIdentifier: "NoCameraSegueID", sender: nil)
        print(error)
    }
    
    //MARK: SCNSceneRendererDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        sceneView.scene.attribute(forKey: SCNScene.Attribute.frameRate.rawValue)
        
        let deltaTime = time - lastUpdateTime
        let currentFPS = 1 / deltaTime
        // to make sure fps is not too small which will result in infinite numbers
        if (currentFPS > 10) {
            let frameRate = Int(currentFPS.rounded())
            let multiplier = 60.0 / Double(frameRate)
            if (sceneView.scene.physicsWorld.speed != CGFloat(multiplier)) {
                sceneView.scene.physicsWorld.speed = CGFloat(multiplier)
                print(multiplier)
                updateMissPlane(multipler: multiplier)
            }
        }
        
        lastUpdateTime = time
    }

    
    
    //MARK: Physics World Delegate
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        
        // 1. Collisions made during tutorial
        if (tutorialInProgress == true) {
            // a) Part 1 of tutorial when ball comes and hits phone
            if (contact.nodeA.name == PhonePlaneConstants.name || contact.nodeB.name == PhonePlaneConstants.name) {
                // collision with ball
                if (contact.nodeA.name == BallConstants.name || contact.nodeB.name == BallConstants.name) {
                    DispatchQueue.main.async {
                        self.heavyFeedbackGenerator.prepare()
                        self.heavyFeedbackGenerator.impactOccurred()
                    }
                    score = score + 1
                    if let caughtBallSound = soundManager.caughtBallSound() {
                        let caughtSound = SCNAction.playAudio(caughtBallSound, waitForCompletion: true)
                        contact.nodeA.runAction(caughtSound)
                    }
                    if (contact.nodeA.name == BallConstants.name) {
                        contact.nodeA.removeFromParentNode()
                    } else if (contact.nodeB.name == BallConstants.name) {
                        contact.nodeB.removeFromParentNode()
                    }
                    tutorialBomb = nodeGenerator.getBomb()
                    self.sceneView.pointOfView?.addChildNode(tutorialBomb)
                    tutorialBomb.position = SCNVector3(0, 0.75, -1)
                    let moveTutorialBomb = SCNAction.moveBy(x: 0, y: -0.6, z: 0, duration: 0.5)
                    let rotateBomb = SCNAction.rotateBy(x: 0, y: CGFloat(2 * Double.pi), z: 0, duration: 5.0)
                    let rotateForever = SCNAction.repeatForever(rotateBomb)
                    tutorialBomb.runAction(SCNAction.group([moveTutorialBomb, rotateForever]))
                    return
                }
            }
            // b) Part 2 of tutorial when bullet hits bomb
            if (contact.nodeA.name == "bullet" || contact.nodeB.name == "bullet") {
                if (contact.nodeA.name == BombConstants.name || contact.nodeB.name == BombConstants.name) {
                    let bombSound = soundManager.bombPop
                    if (contact.nodeA.name == BombConstants.name) {
                        contact.nodeA.removeAllParticleSystems()
                        if let bombSound = bombSound {
                            let burstSound = SCNAction.playAudio(bombSound, waitForCompletion: true)
                            contact.nodeA.runAction(burstSound)
                        }
                        contact.nodeA.addParticleSystem(SCNParticleSystem(named: "ExplosionSmall.scnp", inDirectory: nil)!)
                        
                    } else if (contact.nodeB.name == BombConstants.name) {
                        contact.nodeB.removeAllParticleSystems()
                        contact.nodeB.addParticleSystem(SCNParticleSystem(named: "ExplosionSmall.scnp", inDirectory: nil)!)
                        if let bombSound = bombSound {
                            let burstSound = SCNAction.playAudio(bombSound, waitForCompletion: true)
                            contact.nodeA.runAction(burstSound)
                        }
                    }
                    // strong boom vibration
                    let pop = SystemSoundID(1520)
                    AudioServicesPlaySystemSound(pop)
                    contact.nodeA.physicsBody = nil
                    contact.nodeB.physicsBody = nil
                    contact.nodeA.geometry?.firstMaterial?.diffuse.contents = UIColor.clear
                    contact.nodeB.geometry?.firstMaterial?.diffuse.contents = UIColor.clear
                    bombOnScreen = false
                    self.removeBullets()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        contact.nodeB.removeFromParentNode()
                        contact.nodeA.removeFromParentNode()
                    }
                    tutorialInProgress = false
                    return
                }
            }
            
        }
        
        let bombSound = soundManager.bombPop
        // 2. Collisions after game has started
        if (gameStarted) {
            // a) check for bullet and bomb collision if bomb is on screen
            if (bombOnScreen == true) {
                if (contact.nodeA.name == "bullet" || contact.nodeB.name == "bullet") {
                    // create explosion effect for collision
                    if (contact.nodeA.name == BombConstants.name || contact.nodeB.name == BombConstants.name) {
                        if (contact.nodeA.name == BombConstants.name) {
                            contact.nodeA.removeAllParticleSystems()
                            contact.nodeA.addParticleSystem(SCNParticleSystem(named: "ExplosionSmall.scnp", inDirectory: nil)!)
                            if let bombSound = bombSound {
                                let burstSoundAction = SCNAction.playAudio(bombSound, waitForCompletion: true)
                                contact.nodeA.runAction(burstSoundAction)
                            }
                            
                        } else if (contact.nodeB.name == BombConstants.name) {
                            contact.nodeB.removeAllParticleSystems()
                            contact.nodeB.addParticleSystem(SCNParticleSystem(named: "ExplosionSmall.scnp", inDirectory: nil)!)
                            if let bombSound = bombSound {
                                let burstSoundAction = SCNAction.playAudio(bombSound, waitForCompletion: true)
                                contact.nodeB.runAction(burstSoundAction)
                            }
    
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
                        // remove bullets and nodes
                        self.removeBullets()
                        // remove after 0.6 so full explode sound is played
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                            contact.nodeB.removeFromParentNode()
                            contact.nodeA.removeFromParentNode()
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            self.addObject()
                        }
                        return
                    }
                }
            }
            
            // b) successful collisison with phone
            if (contact.nodeA.name == PhonePlaneConstants.name || contact.nodeB.name == PhonePlaneConstants.name) {
                // Collision with ball
                if (contact.nodeA.name == BallConstants.name || contact.nodeB.name == BallConstants.name) {
                    DispatchQueue.main.async {
                        self.heavyFeedbackGenerator.prepare()
                        self.heavyFeedbackGenerator.impactOccurred()
                    }
                    score = score + 1
                    if let caughtBallSound = soundManager.caughtBallSound() {
                        let caughtSoundAction = SCNAction.playAudio(caughtBallSound, waitForCompletion: true)
                        contact.nodeA.runAction(caughtSoundAction)
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        self.addObject()
                    }
                } else {
                    // Collision with bomb: Game Over
                    let vibrate = SystemSoundID(kSystemSoundID_Vibrate)
                    AudioServicesPlaySystemSound(vibrate)
                    if (contact.nodeA.name == BombConstants.name) {
                        contact.nodeA.removeFromParentNode()
                        contact.nodeB.addParticleSystem(SCNParticleSystem(named: "ExplosionSmall.scnp", inDirectory: nil)!)
                        if let bombSound = bombSound {
                            let burstSoundAction = SCNAction.playAudio(bombSound, waitForCompletion: true)
                            contact.nodeB.runAction(burstSoundAction)
                        }
                    } else if (contact.nodeB.name == BombConstants.name) {
                        contact.nodeB.removeFromParentNode()
                        contact.nodeA.addParticleSystem(SCNParticleSystem(named: "ExplosionSmall.scnp", inDirectory: nil)!)
                        if let bombSound = bombSound {
                            let burstSoundAction = SCNAction.playAudio(bombSound, waitForCompletion: true)
                            contact.nodeA.runAction(burstSoundAction)
                        }
                    }
                    bombOnScreen = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self.gameStarted = false
                        self.performSegue(withIdentifier: "GameOverSegue", sender: nil)
                    }
                }
            // c) Missed phone plane
            } else if (contact.nodeA.name == MissPlaneConstants.name || contact.nodeB.name == MissPlaneConstants.name) {
                // Colission with ball
                if (contact.nodeA.name == BallConstants.name || contact.nodeB.name == BallConstants.name) {
                    numBallMisses = numBallMisses + 1
                    if let missSound = soundManager.missSound {
                        let missSoundAction = SCNAction.playAudio(missSound, waitForCompletion: true)
                        contact.nodeA.runAction(missSoundAction)
                    }
                
                }
                // ignore node with "NA", this is old bomb which is going to be removed
                if (contact.nodeA.name != "NA" && contact.nodeB.name != "NA") {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
                        if (self.numBallMisses == 3) {
                            self.gameStarted = false
                            self.performSegue(withIdentifier: "GameOverSegue", sender: nil)
                        } else {
                            self.addObject()
                        }
                    }
                }
            }
            
            if (contact.nodeA.name == BallConstants.name) {
                contact.nodeA.removeFromParentNode()
            } else if (contact.nodeB.name == BallConstants.name) {
                contact.nodeB.removeFromParentNode()
            }
            
            // if bomb, remove after delay so positional audio can be heard
            var bomb: SCNNode?
            if (contact.nodeA.name == BombConstants.name) {
                bomb = contact.nodeA
            }
            if (contact.nodeB.name == BombConstants.name) {
                bomb = contact.nodeB
            }
            if let bomb = bomb {
                score = score + 1
                bomb.removeAllParticleSystems()
                bomb.geometry?.firstMaterial?.diffuse.contents = UIColor.clear
                bomb.name = "NA"
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    bomb.removeFromParentNode()
                }
            }
            self.removeBullets()
        }
    }
    
    //MARK: Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "GameOverSegue") {
            sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
                if (node.name == "ball" || node.name == "bomb") {
                    node.removeFromParentNode()
                }
            }
            if let gameOverVC = segue.destination as? GameOverViewController {
                gameOverVC.score = score
            }
        } else if (segue.identifier == "gameToTutorialSegueID") {
            if let tutorialVC = segue.destination as? TutorialViewController {
                tutorialVC.delegate = self
            }
        }
    }
    
    // unwind segue to retry game
    @IBAction func unwindFromRetry(segue:UIStoryboardSegue) {
        menuOnScreen = false
        gameStarted = false
        self.pregameSetUp()
    }
    
    // unwind segue from main menu to begin game
    @IBAction func unwindToStartGame(segue:UIStoryboardSegue) {
        if (!TutorialCompletion().completedTutorial) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.showTutorial()
            }
        } else {
            let moveBall = SCNAction.move(to: SCNVector3(0, 0, -20), duration: 1.0)
            moveBall.timingMode = .easeIn
            setUpBall.runAction(moveBall)
            self.pregameSetUp()
        }
    }
    
    // unwind segue from game over screen to go to menu 
    @IBAction func unwindToGoToMenu(segue:UIStoryboardSegue) {
        menuOnScreen = true
        gameStarted = false 
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.menuShowingSetUp()
        }
    }
    
    
    @IBAction func unwindFromTutorial(segue:UIStoryboardSegue) {
        self.pregameSetUp()
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

