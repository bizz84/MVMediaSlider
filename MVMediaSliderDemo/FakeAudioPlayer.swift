//
//  FakeAudioPlayer.swift
//  MVMediaSlider
//
//  Created by Andrea Bizzotto on 04/02/2016.
//  Copyright © 2016 musevisions. All rights reserved.
//

import UIKit

class FakeAudioPlayer: AudioPlayer {

    var timer: NSTimer?

    init() {
        currentTime = 0
    }
    var duration: NSTimeInterval {
        return 115.0
    }
    
    var currentTime: NSTimeInterval
    
    func play() -> Bool {

        if let timer = timer where timer.valid {
            return true
        }
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "updateTime:", userInfo: nil, repeats: true)
        return true
    }
    
    func pause() {
        
        timer?.invalidate()
    }
    
    @objc func updateTime(sender: AnyObject) {
        currentTime = currentTime + 1.0 > duration ? 0 : currentTime + 1
    }

}
