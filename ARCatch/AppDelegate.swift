//
//  AppDelegate.swift
//  ARCatch
//
//  Created by Naman Kedia on 5/17/18.
//  Copyright © 2018 Naman Kedia. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
//        Thread.sleep(forTimeInterval: 1.0)
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        if let gameVC = self.window?.rootViewController as? GameViewController {
            if (gameVC.gameStarted == true) {
               gameVC.sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
                    if (node.name == "ball" || node.name == "bomb") {
                        node.removeFromParentNode()
                    }
                }
                gameVC.performSegue(withIdentifier: "GameOverSegue", sender: nil)
            }

        }
    }
}

