//
//  MVMediaSlider.swift
//  MVMediaSlider
//
//  Created by Andrea Bizzotto on 03/02/2016.
//  Copyright © 2016 musevisions. All rights reserved.
//

import UIKit

extension NSDateComponentsFormatter {
    
    // http://stackoverflow.com/questions/4933075/nstimeinterval-to-hhmmss
    class func string(timeInterval timeInterval: NSTimeInterval, prefix: String = "", fallback: String = "0:00") -> String {
        
        let formatter = NSDateComponentsFormatter()
        formatter.zeroFormattingBehavior = .Pad
        formatter.allowedUnits = timeInterval >= 3600 ? [.Hour, .Minute, .Second] : [.Minute, .Second]
        return prefix + (formatter.stringFromTimeInterval(timeInterval) ?? fallback)
    }
}

extension UIView {
    
    func anchorToSuperview() {
        
        if let superview = self.superview {
            self.translatesAutoresizingMaskIntoConstraints = false
            
            superview.addConstraints([
                NSLayoutConstraint(item: self, attribute: .Left, relatedBy: .Equal, toItem: superview, attribute: .Left, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: self, attribute: .Top, relatedBy: .Equal, toItem: superview, attribute: .Top, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: self, attribute: .Right, relatedBy: .Equal, toItem: superview, attribute: .Right, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: self, attribute: .Bottom, relatedBy: .Equal, toItem: superview, attribute: .Bottom, multiplier: 1, constant: 0),
                ])
        }
    }
}

@IBDesignable
public class MVMediaSlider: UIView {

    @IBOutlet private var leftLabelHolder: UIView!
    @IBOutlet private var leftLabel: UILabel!

    @IBOutlet private var rightLabelHolder: UIView!
    @IBOutlet private var rightLabel: UILabel!
    
    @IBOutlet private var elapsedTimeView: UIView!
    @IBOutlet private var sliderView: UIView!
    
    @IBOutlet private var elapsedTimeViewWidthConstraint: NSLayoutConstraint!

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        if let frameworkBundle = NSBundle(identifier: "com.musevisions.iOS.MVMediaSlider"),
            let view = frameworkBundle.loadNibNamed("MVMediaSlider", owner: self, options: nil).first as? UIView {

            self.addSubview(view)

            view.anchorToSuperview()
        }
    }

    @IBInspectable public var elapsedViewColor: UIColor! {
        didSet {
            leftLabelHolder?.backgroundColor = elapsedViewColor
            elapsedTimeView?.backgroundColor = elapsedViewColor
            sliderView?.backgroundColor = elapsedViewColor
        }
    }
    override public var backgroundColor: UIColor! {
        didSet {
            rightLabelHolder?.backgroundColor = self.backgroundColor
        }
    }
    
    public var totalTime: NSTimeInterval! {
        didSet {
            updateView(currentTime: currentTime ?? 0, totalTime: totalTime)
        }
    }
    public var currentTime: NSTimeInterval! {
        didSet {
            let totalTime = self.totalTime ?? 0
            let currentTime = self.currentTime > totalTime ? totalTime: self.currentTime
            updateView(currentTime: currentTime, totalTime: totalTime ?? 0)
        }
    }
    
    private func updateView(currentTime currentTime: NSTimeInterval, totalTime: NSTimeInterval) {
        
        let normalizedTime = totalTime > 0 ? currentTime / totalTime : 0
        let availableWidth = self.frame.width - leftLabelHolder.frame.width - rightLabelHolder.frame.width - sliderView.frame.width
        elapsedTimeViewWidthConstraint.constant = CGFloat(normalizedTime) * availableWidth
        
        leftLabel.text = NSDateComponentsFormatter.string(timeInterval: currentTime)
        
        let remainingTime = totalTime - currentTime
        rightLabel.text = NSDateComponentsFormatter.string(timeInterval: remainingTime, prefix: "-")
    }
    
    
}
