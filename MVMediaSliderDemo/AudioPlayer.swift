//
//  AudioPlayer.swift
//  MVMediaSlider
//
//  Created by Andrea Bizzotto on 04/02/2016.
//  Copyright © 2016 musevisions. All rights reserved.
//

import UIKit

protocol AudioPlayer {

    var duration: NSTimeInterval { get }
    
    var currentTime: NSTimeInterval { get set }
    
    func play() -> Bool
    
    func pause()
}
