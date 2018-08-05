//
//  ARCatchColors.swift
//  ARCatch
//
//  Created by Naman Kedia on 8/3/18.
//  Copyright © 2018 Naman Kedia. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    class func ARCatchNormalRedColor() -> UIColor {
        return UIColor(red: (203/255.0), green: (24/255.0), blue: (23/255.0), alpha: 1.0)
    }
    class func ARCatchHighligtedRedColor() -> UIColor {
        return UIColor(red: (160/255.0), green: (2/255.0), blue: (2/255.0), alpha: 1.0)
    }
    
    class func ARCatchConfettiColors() -> [UIColor] {
        return [UIColor(red:0.95, green:0.40, blue:0.27, alpha:1.0),
        UIColor(red:1.00, green:0.78, blue:0.36, alpha:1.0),
        UIColor(red:0.48, green:0.78, blue:0.64, alpha:1.0),
        UIColor(red:0.30, green:0.76, blue:0.85, alpha:1.0),
        UIColor(red:0.58, green:0.39, blue:0.55, alpha:1.0)]
    }
    
}
