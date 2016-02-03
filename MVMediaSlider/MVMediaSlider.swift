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
        let minusString = timeInterval >= 1.0 ? prefix : ""
        return minusString + (formatter.stringFromTimeInterval(timeInterval) ?? fallback)
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
public class MVMediaSlider: UIControl {

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
            sliderView?.backgroundColor = UIColor.yellowColor()
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
            if !draggingInProgress {
                let totalTime = self.totalTime ?? 0
                let currentTime = self.currentTime > totalTime ? totalTime: self.currentTime
                updateView(currentTime: currentTime, totalTime: totalTime ?? 0)
            }
        }
    }
    
    private var availableSliderWidth: CGFloat {
        return self.frame.width - leftLabelHolder.frame.width - rightLabelHolder.frame.width - sliderView.frame.width
    }
    
    private func updateView(currentTime currentTime: NSTimeInterval, totalTime: NSTimeInterval) {
        
        let normalizedTime = totalTime > 0 ? currentTime / totalTime : 0
        elapsedTimeViewWidthConstraint.constant = CGFloat(normalizedTime) * availableSliderWidth
        
        leftLabel.text = NSDateComponentsFormatter.string(timeInterval: currentTime)
        
        let remainingTime = totalTime - currentTime
        rightLabel.text = NSDateComponentsFormatter.string(timeInterval: remainingTime, prefix: "-")
    }
    
    // MARK: UIControl overrides
    private let DragCaptureDeltaX: CGFloat = 22
    
    var draggingInProgress = false
    var initialDragLocationX: CGFloat = 0
    var initialSliderConstraintValue: CGFloat = 0
    
    override public func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        
        let sliderCenterX = leftLabelHolder.frame.width + elapsedTimeViewWidthConstraint.constant + sliderView.bounds.width / 2
        draggingInProgress = true
        
        let locationX = touch.locationInView(self).x
        
        let beginTracking = locationX > sliderCenterX - DragCaptureDeltaX && locationX < sliderCenterX + DragCaptureDeltaX
        if beginTracking {
            initialDragLocationX = locationX
            initialSliderConstraintValue = elapsedTimeViewWidthConstraint.constant
        }
        return beginTracking
    }
    
    override public func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        
        let newValue = newSliderValue(touch)
        
        let seekTime = NSTimeInterval(newValue / availableSliderWidth) * totalTime
        
        updateView(currentTime: seekTime, totalTime: totalTime ?? 0)
        
        return true
    }

    override public func endTrackingWithTouch(touch: UITouch?, withEvent event: UIEvent?) {
        
        draggingInProgress = false
        guard let touch = touch else {
            updateView(currentTime: currentTime ?? 0, totalTime: totalTime ?? 0)
            return
        }
        
        let newValue = newSliderValue(touch)
        
        currentTime = NSTimeInterval(newValue / availableSliderWidth) * totalTime
        
        self.sendActionsForControlEvents(.ValueChanged)
    }
    
    func newSliderValue(touch: UITouch) -> CGFloat {
        
        let locationX = touch.locationInView(self).x
        
        let deltaX = locationX - initialDragLocationX
        
        let adjustedSliderValue = initialSliderConstraintValue + deltaX
        
        return max(0, min(adjustedSliderValue, availableSliderWidth))
    }
    
}
