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

    let totalTime: NSTimeInterval = 60 * 1
    var currentTime: NSTimeInterval = 0
    
    var timer: NSTimer?
    
    var audioPlayer: AudioPlayer?
    
    @IBOutlet var mediaSlider: MVMediaSlider!
    
    @IBOutlet var playButton: UIButton!

    var playing: Bool = false {
        didSet {
            playButton.selected = playing
            if (playing) {
                timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "fire:", userInfo: nil, repeats: true)
            }
            else {
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
        
        mediaSlider.totalTime = totalTime
        mediaSlider.currentTime = 0
        

        loadAudio()
    }
    
    func loadAudio() {
        
        do {
            let audioPlayer = try AudioPlayer.load("song", type: "mp3", playImmediately: false)
            mediaSlider.totalTime = audioPlayer.duration
            mediaSlider.currentTime = 0
            self.audioPlayer = audioPlayer
        }
        catch {
            print("Error loading: \(error)")
        }
    }
    
    // MARK: IBActions
    @IBAction func sliderValueChanged(sender: MVMediaSlider) {
        
        currentTime = sender.currentTime ?? 0
    }
    
    @IBAction func backTapped(sender: UIButton) {
        updateCurrentTime(offset: -10)
    }

    @IBAction func forwardTapped(sender: UIButton) {
        updateCurrentTime(offset: 10)
    }
    
    @IBAction func playTapped(sender: UIButton) {

        playing = !playing
    }
    
    @objc func fire(sender: AnyObject) {
        
        updateCurrentTime(offset: 1)
    }
    
    func updateCurrentTime(offset offset: NSTimeInterval) {
        currentTime = (currentTime + offset < 0 || currentTime + offset >= totalTime) ? 0 : currentTime + offset
        mediaSlider.currentTime = currentTime
        
//        if offset > 0 && currentTime == 0 {
//            playing = false
//        }
    }

}

