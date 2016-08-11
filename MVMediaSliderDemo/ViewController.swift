/*
MVMediaSlider - Copyright (c) 2016 Andrea Bizzotto bizz84@gmail.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

import UIKit
import MVMediaSlider

class ViewController: UIViewController {

    private let SeekTimeStep = 10.0
    
    private var timer: Timer?
    
    private var audioPlayer: AudioPlayer?
    
    @IBOutlet private var mediaSlider: MVMediaSlider!
    
    @IBOutlet private var playButton: UIButton!

    var playing: Bool = false {
        didSet {
            playButton.isSelected = playing
            if (playing) {
                audioPlayer?.play()
                timer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(ViewController.updateViews(_:)), userInfo: nil, repeats: true)
            }
            else {
                audioPlayer?.pause()
                timer?.invalidate()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "PLAYING"

        loadAudio(false)
    }
    
    private func loadAudio(_ realPlayer: Bool) {

        if realPlayer {
            do {
                let audioPlayer = try RealAudioPlayer.load("SampleAudioFile", type: "mp3", playImmediately: false)
                mediaSlider.totalTime = audioPlayer.duration
                mediaSlider.currentTime = 0
                self.audioPlayer = audioPlayer
            }
            catch {
                print("Error loading: \(error)")
            }

        }
        else {
            let audioPlayer = FakeAudioPlayer()
            mediaSlider.totalTime = audioPlayer.duration
            mediaSlider.currentTime = 0
            self.audioPlayer = audioPlayer
        }
    }
    
    // MARK: IBActions
    @IBAction private func sliderValueChanged(_ sender: MVMediaSlider) {
        
        updatePlayer(currentTime: sender.currentTime ?? 0)
    }
    
    @IBAction private func backTapped(_ sender: UIButton) {
        let newTime = _currentTime - SeekTimeStep > 0 ? _currentTime - SeekTimeStep : 0
        updatePlayer(currentTime: newTime)
    }

    @IBAction private func forwardTapped(_ sender: UIButton) {
        let newTime = _currentTime + SeekTimeStep < _totalTime ? _currentTime + SeekTimeStep : 0
        updatePlayer(currentTime: newTime)
    }
    
    @IBAction private func playTapped(_ sender: UIButton) {

        playing = !playing
    }
    
    @objc private func updateViews(_ sender: AnyObject) {
        
        updateMediaSlider(currentTime: _currentTime)
    }
    
    private func updateMediaSlider(currentTime: TimeInterval) {
        mediaSlider.currentTime = currentTime
    }

    private func updatePlayer(currentTime: TimeInterval) {
        audioPlayer?.currentTime = currentTime
    }
    
    private var _currentTime: TimeInterval {
        return audioPlayer?.currentTime ?? 0
    }
    
    private var _totalTime: TimeInterval {
        return audioPlayer?.duration ?? 0
    }
}

