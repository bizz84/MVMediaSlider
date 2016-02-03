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

    let totalTime: NSTimeInterval = 60 * 1
    var currentTime: NSTimeInterval = 0
    
    @IBOutlet var mediaSlider: MVMediaSlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mediaSlider.backgroundColor = UIColor.redColor()
        mediaSlider.elapsedViewColor = UIColor.greenColor()
        
        mediaSlider.totalTime = totalTime
        mediaSlider.currentTime = 0
    
        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "fire:", userInfo: nil, repeats: true)
    }
    
    @objc func fire(sender: AnyObject) {
        
        currentTime = (currentTime + 1.0) % totalTime
        mediaSlider.currentTime = currentTime
    }
}

