//
//  BackgroundTask.swift
//  MosiacTimer
//
//  Created by Sanjeev on 19/04/19.
//  Copyright © 2019 Sanjeev. All rights reserved.
//

import Foundation
import AVFoundation

class BackgroundTask {
    
    // MARK: - Vars
    var player = AVAudioPlayer()
    var timer = Timer()
    
    // MARK: - Methods
    
    // starting to play blank audio
    func startBackgroundTask() {
        NotificationCenter.default.addObserver(self, selector: #selector(interruptedAudio), name: AVAudioSession.interruptionNotification, object: AVAudioSession.sharedInstance())
        self.playAudio()
    }
    
    // stopping the audio player
    func stopBackgroundTask() {
        NotificationCenter.default.removeObserver(self, name: AVAudioSession.interruptionNotification, object: nil)
        player.stop()
    }
    
    //handling the audio interruption
    @objc fileprivate func interruptedAudio(_ notification: Notification) {
        if notification.name == AVAudioSession.interruptionNotification && notification.userInfo != nil {
            var info = notification.userInfo!
            var intValue = 0
            (info[AVAudioSessionInterruptionTypeKey]! as AnyObject).getValue(&intValue)
            if intValue == 1 { playAudio() }
        }
    }
    
    //audio player creating and playing
    fileprivate func playAudio() {
        do {
            let bundle = Bundle.main.path(forResource: "blank", ofType: "wav")
            let alertSound = URL(fileURLWithPath: bundle!)
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            try self.player = AVAudioPlayer(contentsOf: alertSound)
            // Play audio forever by setting num of loops to -1
            self.player.numberOfLoops = -1
            self.player.volume = 0.01
            self.player.prepareToPlay()
            self.player.play()
        } catch { print(error) }
    }
}
