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
    @IBOutlet weak var tapToContinueLabel: UILabel!
    
    weak var delegate: TutorialViewControllerDelegate?
    
    let instructionTexts = ["move your phone to catch the incoming baseballs", "evade the bombs or tap the screen to shoot them"]
    var stepNumber = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        instructionLabel.text = instructionTexts[0]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 1.0, delay: 0.0, options: [.repeat, .autoreverse], animations: {
            self.tapToContinueLabel.alpha = 0
        }, completion: nil)
    }
    
    @IBAction func didTapScreen(_ sender: Any) {
        if (stepNumber == 1) {
            stepNumber = -1 // in transition
            UIView.transition(with: instructionLabel, duration: 1.0, options: .transitionCrossDissolve, animations: {
                self.instructionLabel.text = self.instructionTexts[1]
            }) { (_) in
                self.stepNumber = 2
            }
            delegate?.replaceBallWithBomb()
        } else if (stepNumber == 2) {
            delegate?.removeBomb()
            performSegue(withIdentifier: "unwindFromTutorialID", sender: nil)
        }
        
    }
    

}
