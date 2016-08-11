/*
MVMediaSlider - Copyright (c) 2016 Andrea Bizzotto bizz84@gmail.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

import UIKit

class FakeAudioPlayer: AudioPlayer {

    var timer: Timer?

    init() {
        currentTime = 0
    }
    var duration: TimeInterval {
        return 115.0
    }
    
    var currentTime: TimeInterval
    
    func play() -> Bool {

        if let timer = timer where timer.isValid {
            return true
        }
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(FakeAudioPlayer.updateTime(_:)), userInfo: nil, repeats: true)
        return true
    }
    
    func pause() {
        
        timer?.invalidate()
    }
    
    @objc func updateTime(_ sender: AnyObject) {
        currentTime = currentTime + 1.0 > duration ? 0 : currentTime + 1
    }

}
