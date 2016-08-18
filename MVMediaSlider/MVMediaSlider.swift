/*
MVMediaSlider - Copyright (c) 2016 Andrea Bizzotto bizz84@gmail.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

import UIKit

private extension DateComponentsFormatter {
    
    // http://stackoverflow.com/questions/4933075/nstimeinterval-to-hhmmss
    class func string(timeInterval: TimeInterval, prefix: String = "", fallback: String = "0:00") -> String {
        
        let formatter = DateComponentsFormatter()
        formatter.zeroFormattingBehavior = .pad
        formatter.allowedUnits = timeInterval >= 3600 ? [.hour, .minute, .second] : [.minute, .second]
        let minusString = timeInterval >= 1.0 ? prefix : ""
        return minusString + (formatter.string(from: timeInterval) ?? fallback)
    }
}

private extension UIView {
    
    func anchorToSuperview() {
        
        if let superview = self.superview {
            self.translatesAutoresizingMaskIntoConstraints = false
            
            superview.addConstraints([
                makeEqualityConstraint(attribute: .left, toView: superview),
                makeEqualityConstraint(attribute: .top, toView: superview),
                makeEqualityConstraint(attribute: .right, toView: superview),
                makeEqualityConstraint(attribute: .bottom, toView: superview)
            ])
        }
    }
    func makeEqualityConstraint(attribute: NSLayoutAttribute, toView view: UIView) -> NSLayoutConstraint {

        return NSLayoutConstraint(item: self, attribute: attribute, relatedBy: .equal,
            toItem: view, attribute: attribute, multiplier: 1, constant: 0)
    }
}

@IBDesignable open class MVMediaSlider: UIControl {

    // MARK: IBOutlets
    @IBOutlet fileprivate var leftLabelHolder: UIView!
    @IBOutlet fileprivate var leftLabel: UILabel!

    @IBOutlet fileprivate var rightLabelHolder: UIView!
    @IBOutlet fileprivate var rightLabel: UILabel!
    
    @IBOutlet fileprivate var elapsedTimeView: UIView!
    @IBOutlet fileprivate var sliderView: UIView!
    
    @IBOutlet fileprivate var elapsedTimeViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate var sliderWidthConstraint: NSLayoutConstraint!

    @IBOutlet fileprivate var topSeparatorView: UIView!
    @IBOutlet fileprivate var bottomSeparatorView: UIView!

    // MARK: UIControl touch handling variables
    fileprivate let DragCaptureDeltaX: CGFloat = 22
    
    open fileprivate(set) var draggingInProgress = false
    fileprivate var initialDragLocationX: CGFloat = 0
    fileprivate var initialSliderConstraintValue: CGFloat = 0

    // MARK: init
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let bundle = Bundle(for: MVMediaSlider.self)
            
        if let view = bundle.loadNibNamed("MVMediaSlider", owner: self, options: nil)?.first as? UIView {
            
            self.addSubview(view)
            
            view.anchorToSuperview()
        }

        setDefaultValues()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        setDefaultValues()
    }
    
    fileprivate func setDefaultValues() {
        
        elapsedViewColor = UIColor.gray
        sliderColor = UIColor.darkGray
        elapsedTextColor = UIColor.white
        remainingTextColor = UIColor.darkGray
        topSeparatorColor = UIColor.gray
        bottomSeparatorColor = UIColor.gray
    }

    // MARK: styling
    override open var backgroundColor: UIColor! {
        didSet {
            rightLabelHolder?.backgroundColor = self.backgroundColor
        }
    }
    @IBInspectable open var elapsedViewColor: UIColor? {
        get {
            return leftLabelHolder?.backgroundColor
        }
        set(newElapsedViewColor) {
            leftLabelHolder?.backgroundColor = newElapsedViewColor
            elapsedTimeView?.backgroundColor = newElapsedViewColor
            let _ = sliderView?.subviews.map { $0.backgroundColor = newElapsedViewColor }
        }
    }
    @IBInspectable open var sliderColor: UIColor? {
        get {
            return sliderView?.backgroundColor
        }
        set {
            sliderView?.backgroundColor = newValue
        }
    }
    @IBInspectable open var elapsedTextColor: UIColor? {
        get {
            return leftLabel?.textColor
        }
        set {
            leftLabel?.textColor = newValue ?? UIColor.gray
        }
    }
    @IBInspectable open var remainingTextColor: UIColor? {
        get {
            return rightLabel?.textColor
        }
        set {
            rightLabel?.textColor = newValue ?? UIColor.darkGray
        }
    }
    
    @IBInspectable open var topSeparatorColor: UIColor? {
        get {
            return topSeparatorView?.backgroundColor
        }
        set {
            topSeparatorView?.backgroundColor = newValue
        }
    }
    @IBInspectable open var bottomSeparatorColor: UIColor? {
        get {
            return bottomSeparatorView?.backgroundColor
        }
        set {
            bottomSeparatorView?.backgroundColor = newValue
        }
    }
    
    open override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
    }
    
    // IBInspectable should support UIFont: http://www.openradar.me/22835760
    // @IBInspectable
    open var timersFont: UIFont! {
        didSet {
            leftLabel?.font = timersFont
            rightLabel?.font = timersFont
        }
    }
    
    // MARK: time management
    open var totalTime: TimeInterval? {
        didSet {
            updateView(currentTime: _currentTime, totalTime: _totalTime)
        }
    }
    open var currentTime: TimeInterval? {
        didSet {
            if !draggingInProgress {
                let currentTime = min(_currentTime, _totalTime)
                updateView(currentTime: currentTime, totalTime: _totalTime)
            }
        }
    }
    
    // MARK: internal methods
    fileprivate var _totalTime: TimeInterval {
        return totalTime ?? 0
    }
    
    fileprivate var _currentTime: TimeInterval {
        return currentTime ?? 0
    }
    
    fileprivate var availableSliderWidth: CGFloat {
        return self.frame.width - leftLabelHolder.frame.width - rightLabelHolder.frame.width - sliderView.frame.width
    }
    
    fileprivate func updateView(currentTime: TimeInterval, totalTime: TimeInterval) {
        
        let normalizedTime = totalTime > 0 ? currentTime / totalTime : 0
        elapsedTimeViewWidthConstraint?.constant = CGFloat(normalizedTime) * availableSliderWidth
        
        leftLabel?.text = DateComponentsFormatter.string(timeInterval: currentTime)
        
        let remainingTime = totalTime - currentTime
        rightLabel?.text = DateComponentsFormatter.string(timeInterval: remainingTime, prefix: "-")
    }

    // MARK: trait collection
    override open func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if draggingInProgress {
            cancelTracking(with: nil)
            draggingInProgress = false
        }
        updateView(currentTime: _currentTime, totalTime: _totalTime)
    }
}

extension MVMediaSlider {
    
    // MARK: UIControl subclassing
    override open func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        
        self.sendActions(for: .touchDown)

        let sliderCenterX = leftLabelHolder.frame.width + elapsedTimeViewWidthConstraint.constant + sliderView.bounds.width / 2
        
        let locationX = touch.location(in: self).x
        
        let beginTracking = locationX > sliderCenterX - DragCaptureDeltaX && locationX < sliderCenterX + DragCaptureDeltaX
        if beginTracking {
            initialDragLocationX = locationX
            initialSliderConstraintValue = elapsedTimeViewWidthConstraint.constant
        }
        return beginTracking
    }
    
    override open func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        
        if !draggingInProgress {
            draggingInProgress = true
        }
        
        let newValue = sliderValue(touch)
        
        let seekTime = TimeInterval(newValue / availableSliderWidth) * _totalTime
        
        updateView(currentTime: seekTime, totalTime: _totalTime)
        
        return true
    }

    override open func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        
        self.sendActions(for: .touchUpInside)

        draggingInProgress = false

        guard let touch = touch else {
            updateView(currentTime: _currentTime, totalTime: _totalTime)
            return
        }
        
        let newValue = sliderValue(touch)
        
        currentTime = TimeInterval(newValue / availableSliderWidth) * _totalTime
        
        self.sendActions(for: .valueChanged)
    }
    
    fileprivate func sliderValue(_ touch: UITouch) -> CGFloat {
        
        let locationX = touch.location(in: self).x
        
        let deltaX = locationX - initialDragLocationX
        
        let adjustedSliderValue = initialSliderConstraintValue + deltaX
        
        return max(0, min(adjustedSliderValue, availableSliderWidth))
    }
    
}
