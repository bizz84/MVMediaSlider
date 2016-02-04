//
//  ViewController.swift
//  MVMediaSliderDemo
//
//  Created by Andrea Bizzotto on 03/02/2016.
//  Copyright © 2016 musevisions. All rights reserved.
//

import UIKit
import MVMediaSlider

extension UIColor {
    class func base255(r r: CGFloat, g: CGFloat, b: CGFloat) -> UIColor {
        return UIColor(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: 1.0)
    }
}

class ViewController: UIViewController {

    let SeekTimeStep = 10.0
    
    var timer: NSTimer?
    
    var audioPlayer: AudioPlayer?
    
    @IBOutlet var mediaSlider: MVMediaSlider!
    
    @IBOutlet var playButton: UIButton!

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

        mediaSlider.backgroundColor = UIColor.clearColor()
//        mediaSlider.elapsedViewColor = UIColor.base255(r: 253, g: 160, b: 79)
//        mediaSlider.sliderColor = UIColor.base255(r: 252, g: 126, b: 15)
//        mediaSlider.elapsedTextColor = UIColor.whiteColor()
//        mediaSlider.remainingTextColor = UIColor.darkGrayColor()
        

        loadAudio(false)
    }
    
    func loadAudio(realPlayer: Bool) {

        if realPlayer {
            do {
                let audioPlayer = try RealAudioPlayer.load("Endure-Z-Type-Soundrack", type: "mp3", playImmediately: false)
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
    @IBAction func sliderValueChanged(sender: MVMediaSlider) {
        
        updatePlayer(currentTime: sender.currentTime ?? 0)
    }
    
    @IBAction func backTapped(sender: UIButton) {
        let newTime = _currentTime - SeekTimeStep > 0 ? _currentTime - SeekTimeStep : 0
        updatePlayer(currentTime: newTime)
    }

    @IBAction func forwardTapped(sender: UIButton) {
        let newTime = _currentTime + SeekTimeStep < _totalTime ? _currentTime + SeekTimeStep : 0
        updatePlayer(currentTime: newTime)
    }
    
    @IBAction func playTapped(sender: UIButton) {

        playing = !playing
    }
    
    @objc func updateViews(sender: AnyObject) {
        
        updateMediaSlider(currentTime: _currentTime)
    }
    
    func updatePlayer(currentTime currentTime: NSTimeInterval) {
        audioPlayer?.currentTime = currentTime
    }
    
    func updateMediaSlider(currentTime currentTime: NSTimeInterval) {
        mediaSlider.currentTime = currentTime
    }
    
    var _currentTime: NSTimeInterval {
        return audioPlayer?.currentTime ?? 0
    }
    
    var _totalTime: NSTimeInterval {
        return audioPlayer?.duration ?? 0
    }

}

