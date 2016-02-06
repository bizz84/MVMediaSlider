//
//  ViewController.swift
//  MVMediaSliderDemo
//
//  Created by Andrea Bizzotto on 03/02/2016.
//  Copyright © 2016 musevisions. All rights reserved.
//

import UIKit
import MVMediaSlider

class ViewController: UIViewController {

    private let SeekTimeStep = 10.0
    
    private var timer: NSTimer?
    
    private var audioPlayer: AudioPlayer?
    
    @IBOutlet private var mediaSlider: MVMediaSlider!
    
    @IBOutlet private var playButton: UIButton!

    var playing: Bool = false {
        didSet {
            playButton.selected = playing
            if (playing) {
                audioPlayer?.play()
                timer = NSTimer.scheduledTimerWithTimeInterval(0.3, target: self, selector: "updateViews:", userInfo: nil, repeats: true)
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
    
    private func loadAudio(realPlayer: Bool) {

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
    @IBAction private func sliderValueChanged(sender: MVMediaSlider) {
        
        updatePlayer(currentTime: sender.currentTime ?? 0)
    }
    
    @IBAction private func backTapped(sender: UIButton) {
        let newTime = _currentTime - SeekTimeStep > 0 ? _currentTime - SeekTimeStep : 0
        updatePlayer(currentTime: newTime)
    }

    @IBAction private func forwardTapped(sender: UIButton) {
        let newTime = _currentTime + SeekTimeStep < _totalTime ? _currentTime + SeekTimeStep : 0
        updatePlayer(currentTime: newTime)
    }
    
    @IBAction private func playTapped(sender: UIButton) {

        playing = !playing
    }
    
    @objc private func updateViews(sender: AnyObject) {
        
        updateMediaSlider(currentTime: _currentTime)
    }
    
    private func updateMediaSlider(currentTime currentTime: NSTimeInterval) {
        mediaSlider.currentTime = currentTime
    }

    private func updatePlayer(currentTime currentTime: NSTimeInterval) {
        audioPlayer?.currentTime = currentTime
    }
    
    private var _currentTime: NSTimeInterval {
        return audioPlayer?.currentTime ?? 0
    }
    
    private var _totalTime: NSTimeInterval {
        return audioPlayer?.duration ?? 0
    }
}

