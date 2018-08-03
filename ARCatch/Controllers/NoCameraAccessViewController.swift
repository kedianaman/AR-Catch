//
//  NoCameraAccessViewController.swift
//  ARCatch
//
//  Created by Naman Kedia on 8/3/18.
//  Copyright © 2018 Naman Kedia. All rights reserved.
//

import UIKit

class NoCameraAccessViewController: UIViewController {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    @IBAction func settingsClicked(_ sender: Any) {
        SoundManager().buttonTapped()  
        guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
            return
        }
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                print("Settings opened: \(success)") // Prints true
            })
        }
        
    }
    
}
