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
    
    var volumeOn: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: "volumeOnKey")
        }
        get {
            if let volumeOn = UserDefaults.standard.value(forKey: "volumeOnKey") as? Bool {
                return volumeOn
            } else {
                return true
            }
        }
    }
    
    func caughtBallSound() ->  SCNAudioSource? {
        if (volumeOn) {
            let randomNumber = (arc4random() % 7) + 1
            let soundName = "baseball_catch-\(randomNumber).m4a"
            print(soundName)
            return SCNAudioSource(named: soundName)!
        } else {
            return nil
        }
    }
    
    var plopSound: SCNAudioSource? {
        if (volumeOn) {
            return SCNAudioSource(named: "plop.mp3")!
        } else {
            return nil
        }
    }
    
    var missSound: SCNAudioSource? {
        if (volumeOn) {
            return SCNAudioSource(named: "Whoosh.mp3")!
        } else {
            return nil
        }
    }
    
    var bombPop: SCNAudioSource? {
        if (volumeOn) {
            return SCNAudioSource(named: "Grenade.wav")!
        } else {
            return nil
        }
    }
    
    var litFuseAudioPlayer: SCNAudioSource? {
        if (volumeOn) {
            return SCNAudioSource(fileNamed: "litfuse.m4a")!
        } else {
            return nil 
        }
    }
    
}
