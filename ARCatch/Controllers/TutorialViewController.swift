//
//  TutorialViewController.swift
//  ARCatch
//
//  Created by Naman Kedia on 7/31/18.
//  Copyright © 2018 Naman Kedia. All rights reserved.
//

import UIKit

protocol TutorialViewControllerDelegate: class {
    func replaceBallWithBomb()
    func removeBomb()
}

class TutorialViewController: UIViewController {

    @IBOutlet weak var instructionLabel: UILabel!
    
    weak var delegate: TutorialViewControllerDelegate?
    
    let instructionTexts = ["move your phone to catch the incoming baseballs", "evade the bombs or tap the screen to shoot them"]
    var stepNumber = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        instructionLabel.text = instructionTexts[0]
    }
    
    @IBAction func didTapScreen(_ sender: Any) {
        if (stepNumber == 0) {
            stepNumber = stepNumber + 1
            instructionLabel.text = instructionTexts[stepNumber]
            delegate?.replaceBallWithBomb()
            // replace ball with bomb
        } else if (stepNumber == 1) {
            delegate?.removeBomb()
            performSegue(withIdentifier: "unwindFromTutorialID", sender: nil)
            // burst bomb
        }
        
    }
    

}
