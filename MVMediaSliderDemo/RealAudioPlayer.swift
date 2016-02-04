//
//  AudioPlayer.swift
//  MVMediaSlider
//
//  Created by Andrea Bizzotto on 04/02/2016.
//  Copyright © 2016 musevisions. All rights reserved.
//

import UIKit
import AudioToolbox
import AVFoundation

enum AudioPlayerCreateError: ErrorType {
    case ResourceNotFound(resourceName: String, type: String)
    case CreateError(error: ErrorType)
    
}

class RealAudioPlayer: NSObject, AudioPlayer, AVAudioPlayerDelegate {

    let audioPlayer: AVAudioPlayer
    
    class func load(resourceName: String, type: String, playImmediately: Bool) throws -> AudioPlayer {
        
        if let resourcePath = NSBundle.mainBundle().pathForResource(resourceName, ofType: type) {
            let fileURL = NSURL(fileURLWithPath: resourcePath)
           
            do {
                let audioPlayer = try AVAudioPlayer(contentsOfURL: fileURL)
                return RealAudioPlayer(audioPlayer: audioPlayer, playImmediately: playImmediately)
            }
            catch (let error) {
                throw AudioPlayerCreateError.CreateError(error: error)
            }
        }
        else {
            throw AudioPlayerCreateError.ResourceNotFound(resourceName: resourceName, type: type)
        }
    }
    
    private init(audioPlayer: AVAudioPlayer, playImmediately: Bool) {
    
        self.audioPlayer = audioPlayer
        super.init()
        audioPlayer.delegate = self
        audioPlayer.prepareToPlay()
        audioPlayer.numberOfLoops = -1
        if playImmediately {
            audioPlayer.play()
        }
    }
    
    var duration: NSTimeInterval {
        return audioPlayer.duration
    }
    
    var currentTime: NSTimeInterval {
        get {
            return audioPlayer.currentTime
        }
        set {
            audioPlayer.currentTime = newValue
        }
    }
    
    func play() -> Bool {
        return audioPlayer.play()
    }
    
    func pause() {
        audioPlayer.pause()
    }
    
    // MARK: AVAudioPlayerDelegate
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        
        player.stop()
        player.prepareToPlay()
    }
    
    func audioPlayerDecodeErrorDidOccur(player: AVAudioPlayer, error: NSError?) {
        
    }

}
