import UIKit

/// This reusable `CountingLabel` let's the Label count up or down with an rolling an animation
final class CountingLabel: UILabel {
    
    private var startValue: Float = 0.0
    private var endValue: Float = 0.0
    
    private var progress: TimeInterval!
    private var duration: TimeInterval!
    private var lastUpdate: TimeInterval!
    private var timer: Timer?
    
    private let counterVelocity: Float = 3.0
    private var animationType: AnimationType!
    private var counterType: CounterType!
    
    /// this variable holds the current counter value
    private var currentCounterValue: Float {
        if progress >= duration {
            return endValue
        }
        let percentage = Float(progress / duration)
        let update = updateCounter(counterValue: percentage)
        return startValue + (update * (endValue - startValue))
    }
    
    enum AnimationType {
        case linear
        case curveEaseIn
        case curveEaseOut
    }
    
    enum CounterType {
        case Int
        case DoubleOneDigit
        case Float
        case Hex
    }
    
    enum TextAlignment {
        case Left
        case Center
        case Right
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupProperties()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupProperties() {
        setContentHuggingPriority(UILayoutPriority(rawValue: 1000), for: .vertical)
        textColor = themeColors.mainTextColor
        numberOfLines = 0
    }
    
    func count(
        startValue: Float, 
        endValue: Float, 
        duration: TimeInterval, 
        animationType: AnimationType,
        counterType: CounterType,
        textAlignment: TextAlignment, 
        font: String, 
        fontSize: CGFloat
    ) {
        self.startValue = startValue
        self.endValue = endValue
        self.duration = duration
        self.counterType = counterType
        self.animationType = animationType
        self.progress = 0.0
        self.lastUpdate = Date.timeIntervalSinceReferenceDate
        self.font = UIFont(name: font, size: fontSize)
        setTextAlignment(alignment: textAlignment)
        
        invalidateTimer()
        if duration == 0 {
            updateText(value: endValue)
            return
        }
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateValue), userInfo: nil, repeats: true)
    }
    
    private func setTextAlignment(alignment: TextAlignment) {
        switch alignment {
        case .Left:
            self.textAlignment = .left
        case .Center:
            self.textAlignment = .center
        case .Right:
            self.textAlignment = .right
        }
    }
    
    @objc private func updateValue() {
        let now = Date.timeIntervalSinceReferenceDate
        progress = progress + (now - lastUpdate)
        lastUpdate = now
        
        if progress >= duration  {
            invalidateTimer()
            progress = duration
        }
        updateText(value: currentCounterValue)
    }
    
    private func updateText(value: Float) {
        guard let counterType = counterType else { return }
        switch counterType {
        case .Int:
            self.text = "\(Int(value))"
        case .DoubleOneDigit:
            self.text = String(format: "%.1f", value)
        case .Float:
            self.text = String(format: "%.2f", value)
        case .Hex:
            self.text = String(format: "%02X", Int(value))
        }
    }
    
//     private func updateText(value: Float) {
//         let currencySign = UserDefaults.standard.getCurrencySign()
//         let currencyFormatter = NumberFormatter()
//         currencyFormatter.groupingSize = 3
//         currencyFormatter.groupingSeparator = "."
//         currencyFormatter.decimalSeparator = ","
//         currencyFormatter.usesGroupingSeparator = true
//         currencyFormatter.numberStyle = .decimal
//         currencyFormatter.maximumFractionDigits = 2
//         currencyFormatter.minimumFractionDigits = 2
        
//         if currencySign == UserDefaults.UserDefaultsKeys.pondSign.rawValue {
//             currencyFormatter.groupingSeparator = ","
//             currencyFormatter.decimalSeparator = "."
//         }
        
//         if let formattedGrossAmount = currencyFormatter.string(from: value as NSNumber) {
//             self.text = "\(formattedGrossAmount)\(currencySign)"
//         }
//     }    
    
    private func updateCounter(counterValue: Float) -> Float {
        guard let animationType = animationType else { return 0}
        switch animationType {
        case .linear:
            return counterValue
        case .curveEaseIn:
            return powf(counterValue, counterVelocity)
        case .curveEaseOut:
            return 1 - powf(1 - counterValue, counterVelocity)
        }
    }
    
    private func invalidateTimer() {
        timer?.invalidate()
        timer = nil
    }
}
