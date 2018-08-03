//
//  MenuButton.swift
//  ARCatch
//
//  Created by Naman Kedia on 6/8/18.
//  Copyright © 2018 Naman Kedia. All rights reserved.
//

import UIKit

class MenuButton: UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor.white.cgColor
        addShadow(view: self)
    }
    
    func addShadow(view: UIView) {
        view.layer.masksToBounds = false
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowOpacity = 0.5
        view.layer.shadowRadius = 1
    }
    
    
}
