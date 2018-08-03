//
//  SoundManager.swift
//  ARCatch
//
//  Created by Naman Kedia on 8/1/18.
//  Copyright © 2018 Naman Kedia. All rights reserved.
//

import Foundation
import SceneKit
import AVFoundation

class SoundManager {
    
   var tapSoundPlayer = AVAudioPlayer()

    init() {
        let path = Bundle.main.path(forResource: "tap.mp3", ofType:nil)!
        let url = URL(fileURLWithPath: path)
        tapSoundPlayer = try! AVAudioPlayer(contentsOf: url)
        tapSoundPlayer.volume = 0.1
        tapSoundPlayer.prepareToPlay()

    }
    
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
    
    func buttonTapped() {
        if (volumeOn) {
            tapSoundPlayer.play()
            
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
