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

class AudioPlayer: NSObject, AVAudioPlayerDelegate {

    let audioPlayer: AVAudioPlayer
    
    class func load(resourceName: String, type: String, playImmediately: Bool) throws -> AudioPlayer {
        
        if let resourcePath = NSBundle.mainBundle().pathForResource(resourceName, ofType: type) {
            let fileURL = NSURL(fileURLWithPath: resourcePath)
           
            do {
                let audioPlayer = try AVAudioPlayer(contentsOfURL: fileURL)
                return AudioPlayer(audioPlayer: audioPlayer, playImmediately: playImmediately)
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
        self.audioPlayer.delegate = self
        self.audioPlayer.prepareToPlay()
        if playImmediately {
            self.audioPlayer.play()
        }
    }
    
    var duration: NSTimeInterval {
        return self.audioPlayer.duration
    }
    
    var currentTime: NSTimeInterval {
        get {
            return self.audioPlayer.currentTime
        }
        set {
            self.audioPlayer.currentTime = currentTime
        }
    }
    
    // MARK: AVAudioPlayerDelegate
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        
    }
    
    func audioPlayerDecodeErrorDidOccur(player: AVAudioPlayer, error: NSError?) {
        
    }

}
