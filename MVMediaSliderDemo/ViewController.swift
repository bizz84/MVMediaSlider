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
    
    @IBOutlet var mediaSlider: MVMediaSlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mediaSlider.backgroundColor = UIColor.clearColor()
        mediaSlider.elapsedViewColor = UIColor.base255(r: 253, g: 160, b: 79)
        mediaSlider.sliderColor = UIColor.base255(r: 252, g: 126, b: 15)
        mediaSlider.elapsedTextColor = UIColor.whiteColor()
        mediaSlider.remainingTextColor = UIColor.darkGrayColor()
        mediaSlider.layer.borderWidth = 1.0
        mediaSlider.layer.borderColor = UIColor.darkGrayColor().CGColor
        
        mediaSlider.totalTime = totalTime
        mediaSlider.currentTime = 0
            
        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "fire:", userInfo: nil, repeats: true)
    }
    
    
    @IBAction func sliderValueChanged(sender: MVMediaSlider) {
        
        currentTime = sender.currentTime ?? 0
    }
    
    @objc func fire(sender: AnyObject) {
        
        currentTime = currentTime < totalTime ? (currentTime + 1.0) % totalTime : 0
        mediaSlider.currentTime = currentTime
    }
}

