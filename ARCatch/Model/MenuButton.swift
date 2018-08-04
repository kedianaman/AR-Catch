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
    
    fileprivate func updateScaleForHighlightedState() {
        if self.isHighlighted {
            if (self.transform.isIdentity) {
                UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.0, options: UIViewAnimationOptions.beginFromCurrentState, animations: { () -> Void in
                    self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                }, completion: nil)
            }
        }
        else {
            if (self.transform.isIdentity == false) {
                UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.0, options: UIViewAnimationOptions.beginFromCurrentState, animations: { () -> Void in
                    self.transform = CGAffineTransform.identity
                }, completion: nil)
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        updateScaleForHighlightedState()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        updateScaleForHighlightedState()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        updateScaleForHighlightedState()
    }
    
    
}
