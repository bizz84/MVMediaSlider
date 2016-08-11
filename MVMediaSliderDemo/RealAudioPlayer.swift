/*
MVMediaSlider - Copyright (c) 2016 Andrea Bizzotto bizz84@gmail.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

import UIKit
import AudioToolbox
import AVFoundation

enum AudioPlayerCreateError: Error {
    case resourceNotFound(resourceName: String, type: String)
    case createError(error: Error)
    
}

class RealAudioPlayer: NSObject, AudioPlayer, AVAudioPlayerDelegate {

    let audioPlayer: AVAudioPlayer
    
    class func load(_ resourceName: String, type: String, playImmediately: Bool) throws -> AudioPlayer {
        
        if let resourcePath = Bundle.main.path(forResource: resourceName, ofType: type) {
            let fileURL = URL(fileURLWithPath: resourcePath)
           
            do {
                let audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
                return RealAudioPlayer(audioPlayer: audioPlayer, playImmediately: playImmediately)
            }
            catch (let error) {
                throw AudioPlayerCreateError.createError(error: error)
            }
        }
        else {
            throw AudioPlayerCreateError.resourceNotFound(resourceName: resourceName, type: type)
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
    
    var duration: TimeInterval {
        return audioPlayer.duration
    }
    
    var currentTime: TimeInterval {
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
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        
        player.stop()
        player.prepareToPlay()
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        
    }

}
