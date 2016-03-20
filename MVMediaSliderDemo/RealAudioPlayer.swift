/*
MVMediaSlider - Copyright (c) 2016 Andrea Bizzotto bizz84@gmail.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

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
