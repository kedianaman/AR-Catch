//
//  First Launch.swift
//  omgios
//
//  Created by Naman Kedia on 3/19/18.
//  Copyright © 2018 Naman Kedia. All rights reserved.
//

import Foundation

final class TutorialCompletion {

    let userDefaults: UserDefaults = .standard
    let key = "com.ballsAndBombs.FirstLaunch.FinishedTutorial"
    
    var completedTutorial: Bool {
        get {
            return userDefaults.bool(forKey: key)
        }
    }
    
    func setTutorialToComplete() {
        userDefaults.set(true, forKey: key)
    }
}
