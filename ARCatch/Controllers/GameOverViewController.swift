//
//  GameOverViewController.swift
//  ARCatch
//
//  Created by Naman Kedia on 5/24/18.
//  Copyright © 2018 Naman Kedia. All rights reserved.
//

import UIKit

class GameOverViewController: UIViewController {
    
    //MARK: IB Outlets
    @IBOutlet weak var scoreLabel: UILabel!
    
    //MARK: Properties
    var score: Int!
    
    
    //MARK: VC Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        scoreLabel.text = "\(score!)"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.view.layoutSubviews()
    }
}
