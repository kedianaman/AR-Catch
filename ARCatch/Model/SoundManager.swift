//
//  SoundManager.swift
//  ARCatch
//
//  Created by Naman Kedia on 8/1/18.
//  Copyright © 2018 Naman Kedia. All rights reserved.
//

import Foundation
import SceneKit

class SoundManager {
    
    func caughtBallSound() ->  SCNAudioSource {
        let randomNumber = (arc4random() % 7) + 1
        let soundName = "baseball_catch-\(randomNumber).m4a"
        print(soundName)
        return SCNAudioSource(named: soundName)!
    }
}
