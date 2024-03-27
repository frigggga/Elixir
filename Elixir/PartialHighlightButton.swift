import UIKit

func isDeviceMaxSeries() -> Bool {
    if UIDevice.current.userInterfaceIdiom == .phone {
        let screenSize = UIScreen.main.bounds.size

        // List of iPhone Max series and other specified screen sizes
        let targetSizes: [CGSize] = [
            CGSize(width: 414, height: 896), // iPhone XS Max, iPhone 11 Pro Max, iPhone 11, iPhone 12, iPhone 13
            CGSize(width: 428, height: 926), // iPhone 12 Pro Max, iPhone 13 Pro Max
            // iPhone 14 pro max
            CGSize(width: 430, height: 932)
        ]

        return targetSizes.contains(screenSize)
    }
    return false
}

class PartialHighlightTipButton: UIButton {
    
    private var highlightMask: CALayer?
    
    private func setupHighlightMask() {
        highlightMask = CALayer()
        highlightMask?.backgroundColor = UIColor(rgb: 0x316BA0).withAlphaComponent(0.3).cgColor // Customize the highlight color and opacity here
        highlightMask?.cornerRadius = 10 // Customize the corner radius
        if isDeviceMaxSeries() {
            highlightMask?.frame = CGRect(x: 25, y: 0, width: bounds.width / 2.2, height: bounds.height)
        } else {
            highlightMask?.frame = CGRect(x: 15, y: 0, width: bounds.width / 1.63, height: bounds.height) // Customize the frame for the desired highlight area
        }
    }
    
    private func setupButtonAppearance() {
        adjustsImageWhenHighlighted = false
        tintColor = UIColor.clear
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupHighlightMask()
        setupButtonAppearance()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupHighlightMask()
        setupButtonAppearance()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override var isSelected: Bool {
        didSet {
            guard let mask = highlightMask else { return }
            if isSelected {
                layer.addSublayer(mask)
            } else {
                mask.removeFromSuperlayer()
            }
        }
    }
}

class PartialHighlightSuggestionButton: UIButton {
    
    private var highlightMask: CALayer?
    
    private func setupHighlightMask() {
        highlightMask = CALayer()
        highlightMask?.backgroundColor = UIColor(rgb: 0x316BA0).withAlphaComponent(0.3).cgColor // Customize the highlight color and opacity here
        highlightMask?.cornerRadius = 10 // Customize the corner radius
        
        if isDeviceMaxSeries() {
            if UIScreen.main.bounds.size == CGSize(width: 414, height: 896) {
                highlightMask?.frame = CGRect(x: 38, y: 0, width: bounds.width / 1.6, height: bounds.height)
            } else {
                highlightMask?.frame = CGRect(x: 40, y: 0, width: bounds.width / 1.6, height: bounds.height)
            }
        } else {
            highlightMask?.frame = CGRect(x: 26, y: 0, width: bounds.width / 1.43, height: bounds.height) // Customize the frame for the desired highlight area
        }
    }
    
    private func setupButtonAppearance() {
        adjustsImageWhenHighlighted = false
        tintColor = UIColor.clear
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupHighlightMask()
        setupButtonAppearance()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupHighlightMask()
        setupButtonAppearance()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override var isSelected: Bool {
        didSet {
            guard let mask = highlightMask else { return }
            if isSelected {
                layer.addSublayer(mask)
            } else {
                mask.removeFromSuperlayer()
            }
        }
    }
}
