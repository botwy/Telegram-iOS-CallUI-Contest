import Foundation
import UIKit
import AsyncDisplayKit

final class EncryptPanelNode: ASDisplayNode {
    init(origin: CGPoint, nameText : String) {
        super.init()
        self.setViewBlock {
            return EncryptPanelView(origin: origin, nameText: nameText)
        }
    }
    
    var keysView: UIView? {
        return (self.view as? EncryptPanelView)?.keysView
    }
    
    func updateNameText(_ nameText: String) {
        (self.view as? EncryptPanelView)?.updateNameText(nameText)
    }
    
    func onConformTouch(_ touchUpInsideHandler: @escaping (EncryptPanelView) -> Void) {
        (self.view as? EncryptPanelView)?.onConformTouch(touchUpInsideHandler)
    }
}

final class EncryptPanelView: UIView {
    var keysView: UIView?
    var subTitleLabel: UILabel?
    
    private var touchUpInsideHandler: ((EncryptPanelView) -> Void)?
    
    private var paddingX: CGFloat = 16.0
    private var paddingY: CGFloat = 9.0
    private var width: CGFloat = 304.0
    private var height: CGFloat = 225.0
    private var insets = UIEdgeInsets(top: 20, left: 16, bottom: 16, right: 16)
    private let keysHeight: CGFloat = 48
    private let titleLabelHeight: CGFloat = 19
    private let subTitleLabelHeight: CGFloat = 43
    private let buttonHeight: CGFloat = 44
    private let gap: CGFloat = 10.0
    private var fontSize: CGFloat = 16
    
    private var keysY: CGFloat {
        return 0
    }
    
    private var titleLabelY: CGFloat {
        return keysY + keysHeight + gap
    }
    
    private var subTitleLabelY: CGFloat {
        return titleLabelY + titleLabelHeight + gap
    }
    
    private var buttonY: CGFloat {
        return height - buttonHeight
    }
    
    override private init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(origin: CGPoint, nameText : String) {
        self.init(frame: CGRect(origin: origin, size: CGSize()))
        setup(nameText: nameText)
    }
    
   func updateNameText(_ nameText : String) {
       let paragraphStyle = NSMutableParagraphStyle()
       paragraphStyle.lineHeightMultiple = 1.1
       self.subTitleLabel?.attributedText = NSMutableAttributedString(string: "If the emoji on \(nameText) screen are the same, this call is 100% secure.", attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
    }
    
    private func setup(nameText : String) {
        self.frame.size = CGSize(width: self.width, height: self.height)
        let layer = CALayer()
        layer.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.25).cgColor
        layer.compositingFilter = "overlayBlendMode"
        layer.bounds = bounds
        layer.position = center
        self.layer.addSublayer(layer)
        self.layer.cornerRadius = 20
        self.clipsToBounds = true
        createContent(nameText: nameText)
        createConformButton()
    }
    
    private func createContent(nameText : String) {
        let container = UIView(frame: CGRect(x: insets.left, y: insets.top, width: width - insets.left - insets.right, height: height - insets.top - insets.bottom))
        addKeys(container: container)
        addTitle(container: container)
        addSubTitle(container: container, nameText: nameText)
        self.addSubview(container)
    }
    
    private func addKeys(container: UIView) {
        let view = UIView(frame: CGRect(x: 0, y: keysY, width: container.bounds.width, height: keysHeight))
        self.keysView = view
        container.addSubview(view)
    }
    
    private func addTitle(container: UIView) {
        let label = UILabel(frame: CGRect(x: 0, y: titleLabelY, width: container.bounds.width, height: titleLabelHeight))
        label.text = "This call is end-to end encrypted"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: fontSize, weight: UIFont.Weight.semibold)
        label.textAlignment = .center
        container.addSubview(label)
    }
    
    private func addSubTitle(container: UIView, nameText : String) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.1
        let label = UILabel(frame: CGRect(x: 0, y: subTitleLabelY, width: container.bounds.width, height: subTitleLabelHeight))
        label.attributedText = NSMutableAttributedString(string: "If the emoji on \(nameText) screen are the same, this call is 100% secure.", attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: fontSize)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        self.subTitleLabel = label
        container.addSubview(label)
    }
    
    private func createConformButton() {
        let button = UIButton(frame: CGRect(x: 0, y: buttonY, width: width, height: buttonHeight))
        button.setTitle("OK", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.gray, for: .highlighted)
        
        let lineView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: 1))
        lineView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
        button.addSubview(lineView)
        
        button.addTarget(self, action: #selector(self.touchUpInsideAction), for: .touchUpInside)
        self.addSubview(button)
    }
    
    @objc private func touchUpInsideAction() {
        touchUpInsideHandler?(self)
    }
    
    func onConformTouch(_ touchUpInsideHandler: @escaping (EncryptPanelView) -> Void) {
        self.touchUpInsideHandler = touchUpInsideHandler
    }
}
