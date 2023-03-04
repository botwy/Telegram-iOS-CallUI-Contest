import Foundation
import UIKit
import AsyncDisplayKit

final class CallSimpleMessageNode: ASDisplayNode {
    init(maxWidth: CGFloat, title : String) {
        super.init()
        self.setViewBlock {
            return CallSimpleMessageView(maxWidth: maxWidth, title: title)
        }
    }
   
    func updateOrigin(origin: CGPoint) {
        (self.view as? CallSimpleMessageView)?.updateOrigin(origin: origin)
    }
}

final class CallSimpleMessageView: UIView {
    private var title: String = ""
    
    private var maxWidth: CGFloat = 0
    private var insets = UIEdgeInsets(top: 5, left: 12, bottom: 6, right: 12)
    private var font: UIFont = UIFont.systemFont(ofSize: 16)
  
    
    override private init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(maxWidth: CGFloat, title : String) {
        self.init(frame: CGRect())
        self.title = title
        self.maxWidth = maxWidth
        setup()
    }
    
    func updateOrigin(origin: CGPoint) {
        self.frame = CGRect(origin: origin, size: self.bounds.size)
    }
    
    private func setup() {
        let preferredTextSize = CGSize(width: maxWidth, height: .greatestFiniteMagnitude)
        let estimateTextRect = self.title.estimateFrame(preferredSize: preferredTextSize, font: self.font)
        let width = estimateTextRect.width
        let height = estimateTextRect.height
        let titleSize = CGSize(width: width, height: height)
        let sizeWithPadding = CGSize(width: titleSize.width + insets.left + insets.right, height: titleSize.height + insets.top + insets.bottom)
        self.frame = CGRect(origin: self.frame.origin, size: sizeWithPadding)
        let layer = CALayer()
        layer.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.25).cgColor
        layer.compositingFilter = "overlayBlendMode"
        layer.bounds = self.bounds
        layer.position = center
        self.layer.addSublayer(layer)
        self.layer.cornerRadius = 15
        self.clipsToBounds = true
        addTitle(titleSize: titleSize)
    }

    private func addTitle(titleSize: CGSize) {
        let label = UILabel(frame: CGRect(origin: CGPoint(x: insets.left, y: insets.top), size: titleSize))
        label.text = self.title
        label.textColor = .white
        label.font = font
        label.textAlignment = .center
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        self.addSubview(label)
    }
}
