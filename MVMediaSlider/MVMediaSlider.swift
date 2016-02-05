//
//  MVMediaSlider.swift
//  MVMediaSlider
//
//  Created by Andrea Bizzotto on 03/02/2016.
//  Copyright © 2016 musevisions. All rights reserved.
//

import UIKit

private extension NSDateComponentsFormatter {
    
    // http://stackoverflow.com/questions/4933075/nstimeinterval-to-hhmmss
    class func string(timeInterval timeInterval: NSTimeInterval, prefix: String = "", fallback: String = "0:00") -> String {
        
        let formatter = NSDateComponentsFormatter()
        formatter.zeroFormattingBehavior = .Pad
        formatter.allowedUnits = timeInterval >= 3600 ? [.Hour, .Minute, .Second] : [.Minute, .Second]
        let minusString = timeInterval >= 1.0 ? prefix : ""
        return minusString + (formatter.stringFromTimeInterval(timeInterval) ?? fallback)
    }
}

private extension UIView {
    
    func anchorToSuperview() {
        
        if let superview = self.superview {
            self.translatesAutoresizingMaskIntoConstraints = false
            
            superview.addConstraints([
                makeEqualityConstraint(attribute: .Left, toView: superview),
                makeEqualityConstraint(attribute: .Top, toView: superview),
                makeEqualityConstraint(attribute: .Right, toView: superview),
                makeEqualityConstraint(attribute: .Bottom, toView: superview)
            ])
        }
    }
    func makeEqualityConstraint(attribute attribute: NSLayoutAttribute, toView view: UIView) -> NSLayoutConstraint {

        return NSLayoutConstraint(item: self, attribute: attribute, relatedBy: .Equal,
            toItem: view, attribute: attribute, multiplier: 1, constant: 0)
    }
}

@IBDesignable public class MVMediaSlider: UIControl {

    // MARK: IBOutlets
    @IBOutlet private var leftLabelHolder: UIView!
    @IBOutlet private var leftLabel: UILabel!

    @IBOutlet private var rightLabelHolder: UIView!
    @IBOutlet private var rightLabel: UILabel!
    
    @IBOutlet private var elapsedTimeView: UIView!
    @IBOutlet private var sliderView: UIView!
    
    @IBOutlet private var elapsedTimeViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet private var sliderWidthConstraint: NSLayoutConstraint!

    @IBOutlet private var topSeparatorView: UIView!
    @IBOutlet private var bottomSeparatorView: UIView!

    // MARK: UIControl touch handling variables
    private let DragCaptureDeltaX: CGFloat = 22
    
    private var draggingInProgress = false
    private var initialDragLocationX: CGFloat = 0
    private var initialSliderConstraintValue: CGFloat = 0

    // MARK: init
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let bundle = NSBundle(forClass: MVMediaSlider.self)
            
        if let view = bundle.loadNibNamed("MVMediaSlider", owner: self, options: nil).first as? UIView {
            
            self.addSubview(view)
            
            view.anchorToSuperview()
        }

        setDefaultValues()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        setDefaultValues()
    }
    
    private func setDefaultValues() {
        
        elapsedViewColor = UIColor.grayColor()
        sliderColor = UIColor.darkGrayColor()
        elapsedTextColor = UIColor.whiteColor()
        remainingTextColor = UIColor.darkGrayColor()
        topSeparatorColor = UIColor.grayColor()
        bottomSeparatorColor = UIColor.grayColor()
    }

    // MARK: styling
    override public var backgroundColor: UIColor! {
        didSet {
            rightLabelHolder?.backgroundColor = self.backgroundColor
        }
    }
    @IBInspectable public var elapsedViewColor: UIColor! {
        didSet {
            leftLabelHolder?.backgroundColor = elapsedViewColor
            elapsedTimeView?.backgroundColor = elapsedViewColor
            if let lines = sliderView?.subviews {
                for line in lines {
                    line.backgroundColor = elapsedViewColor
                }
            }
        }
    }
    @IBInspectable public var sliderColor: UIColor! {
        didSet {
            sliderView?.backgroundColor = sliderColor
        }
    }
    @IBInspectable public var elapsedTextColor: UIColor! {
        didSet {
            leftLabel?.textColor = elapsedTextColor ?? UIColor.grayColor()
        }
    }
    @IBInspectable public var remainingTextColor: UIColor! {
        didSet {
            rightLabel?.textColor = remainingTextColor ?? UIColor.darkGrayColor()
        }
    }
    
    @IBInspectable public var topSeparatorColor: UIColor? {
        didSet {
            topSeparatorView?.backgroundColor = topSeparatorColor
        }
    }
    @IBInspectable public var bottomSeparatorColor: UIColor? {
        didSet {
            bottomSeparatorView?.backgroundColor = bottomSeparatorColor
        }
    }
    
    // IBInspectable should support UIFont: http://www.openradar.me/22835760
    // @IBInspectable
    public var timersFont: UIFont! {
        didSet {
            leftLabel?.font = timersFont
            rightLabel?.font = timersFont
        }
    }
    
    // MARK: time management
    public var totalTime: NSTimeInterval? {
        didSet {
            updateView(currentTime: _currentTime, totalTime: _totalTime)
        }
    }
    public var currentTime: NSTimeInterval? {
        didSet {
            if !draggingInProgress {
                let currentTime = min(_currentTime, _totalTime)
                updateView(currentTime: currentTime, totalTime: _totalTime)
            }
        }
    }
    
    // MARK: internal methods
    private var _totalTime: NSTimeInterval {
        return totalTime ?? 0
    }
    
    private var _currentTime: NSTimeInterval {
        return currentTime ?? 0
    }
    
    private var availableSliderWidth: CGFloat {
        return self.frame.width - leftLabelHolder.frame.width - rightLabelHolder.frame.width - sliderView.frame.width
    }
    
    private func updateView(currentTime currentTime: NSTimeInterval, totalTime: NSTimeInterval) {
        
        let normalizedTime = totalTime > 0 ? currentTime / totalTime : 0
        elapsedTimeViewWidthConstraint?.constant = CGFloat(normalizedTime) * availableSliderWidth
        
        leftLabel?.text = NSDateComponentsFormatter.string(timeInterval: currentTime)
        
        let remainingTime = totalTime - currentTime
        rightLabel?.text = NSDateComponentsFormatter.string(timeInterval: remainingTime, prefix: "-")
    }

    // MARK: trait collection
    override public func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if draggingInProgress {
            cancelTrackingWithEvent(nil)
            draggingInProgress = false
        }
        updateView(currentTime: _currentTime, totalTime: _totalTime)
    }
}

extension MVMediaSlider {
    
    // MARK: UIControl subclassing
    override public func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        
        let sliderCenterX = leftLabelHolder.frame.width + elapsedTimeViewWidthConstraint.constant + sliderView.bounds.width / 2
        
        let locationX = touch.locationInView(self).x
        
        let beginTracking = locationX > sliderCenterX - DragCaptureDeltaX && locationX < sliderCenterX + DragCaptureDeltaX
        if beginTracking {
            initialDragLocationX = locationX
            initialSliderConstraintValue = elapsedTimeViewWidthConstraint.constant
        }
        return beginTracking
    }
    
    override public func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        
        if !draggingInProgress {
            draggingInProgress = true
        }
        
        let newValue = sliderValue(touch)
        
        let seekTime = NSTimeInterval(newValue / availableSliderWidth) * _totalTime
        
        updateView(currentTime: seekTime, totalTime: _totalTime)
        
        return true
    }

    override public func endTrackingWithTouch(touch: UITouch?, withEvent event: UIEvent?) {
        
        draggingInProgress = false

        guard let touch = touch else {
            updateView(currentTime: _currentTime, totalTime: _totalTime)
            return
        }
        
        let newValue = sliderValue(touch)
        
        currentTime = NSTimeInterval(newValue / availableSliderWidth) * _totalTime
        
        self.sendActionsForControlEvents(.ValueChanged)
    }
    
    private func sliderValue(touch: UITouch) -> CGFloat {
        
        let locationX = touch.locationInView(self).x
        
        let deltaX = locationX - initialDragLocationX
        
        let adjustedSliderValue = initialSliderConstraintValue + deltaX
        
        return max(0, min(adjustedSliderValue, availableSliderWidth))
    }
    
}
