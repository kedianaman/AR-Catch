//
//  MainMenuViewController.swift
//  ARCatch
//
//  Created by Naman Kedia on 5/23/18.
//  Copyright © 2018 Naman Kedia. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class MainMenuViewController: UIViewController, ARSessionDelegate {
    
    let configuration = ARWorldTrackingConfiguration()
    
    @IBOutlet weak var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.session.run(configuration)
        sceneView.autoenablesDefaultLighting = true
        self.sceneView.session.delegate = self
        setUpView()
    }
    
    func setUpView() {
       addTitle()
        addPlayButton()
    }
    
    func addTitle() {
        let titleNode = SCNNode()
        let titleGeometry = SCNText(string: "AR Catch", extrusionDepth: 0.5)
        titleGeometry.chamferRadius = 0.2
        titleGeometry.flatness = 0.2
        titleNode.geometry = titleGeometry
        titleNode.geometry?.firstMaterial?.specular.contents = UIColor(white: 1.0, alpha: 1.0)
        titleNode.position = SCNVector3(0, 0.2, -1)
        titleNode.scale = SCNVector3(0.01, 0.01, 0.01)
        let (minVec, maxVec) = titleNode.boundingBox
        titleNode.pivot = SCNMatrix4MakeTranslation((maxVec.x - minVec.x) / 2 + minVec.x, (maxVec.y - minVec.y) / 2 + minVec.y, 0)
        sceneView.pointOfView?.addChildNode(titleNode)
    }
    
    func addPlayButton() {
        let playNode = SCNNode()
        let playGeometry = SCNText(string: "Play Now", extrusionDepth: 1)
        playGeometry.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        playGeometry.chamferRadius = 0.2
        playGeometry.flatness = 0.2
        playNode.geometry = playGeometry
        playNode.geometry?.firstMaterial?.specular.contents = UIColor(white: 1.0, alpha: 1.0)
        playNode.position = SCNVector3(0, -0.2, -1.5)
        playNode.scale = SCNVector3(0.01, 0.01, 0.01)
        let (minVec, maxVec) = playNode.boundingBox
        playNode.pivot = SCNMatrix4MakeTranslation((maxVec.x - minVec.x) / 2 + minVec.x, (maxVec.y - minVec.y) / 2 + minVec.y, 0)
        playNode.name = "play"
        sceneView.pointOfView?.addChildNode(playNode)
    }
    
    // MARK: AR Session Delegate
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        let cameraPosition = frame.camera.transform.position()
//        print(cameraPosition)
        if let titleNode = sceneView.scene.rootNode.childNodes.first {
            let moveNode = SCNAction.move(to: SCNVector3(-cameraPosition.x, -cameraPosition.y, -cameraPosition.z), duration: 0.1)
            moveNode.timingMode = .easeInEaseOut
            titleNode.runAction(moveNode)
        }
    }
    @IBAction func didTapOnScreen(_ sender: UITapGestureRecognizer) {
        if let node = sceneView.hitTest(sender.location(in: sceneView), options: nil).first?.node {
            if (node.name == "play") {
                print("hit play node" )
                performSegue(withIdentifier: "menuToGameSegue", sender: nil)
            }
        }
    }
}

// MARK: Extensions

extension matrix_float4x4 {
    func position() -> SCNVector3 {
        return SCNVector3(columns.3.x, columns.3.y, columns.3.z)
    }
}
