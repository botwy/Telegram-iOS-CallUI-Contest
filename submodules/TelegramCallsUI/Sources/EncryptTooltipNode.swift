import Foundation
import UIKit
import AsyncDisplayKit

struct EncryptTooltipRectConfig {
    let maxX: CGFloat
    let minY: CGFloat
    let contentMaxWidth: Double
    let contentMinHeight: Double
    let paddingX: CGFloat?
    let paddingY: CGFloat?
    
    init(maxX: CGFloat, minY: CGFloat, contentMaxWidth: Double, contentMinHeight: Double, paddingX: CGFloat? = nil, paddingY: CGFloat? = nil) {
        self.maxX = maxX
        self.minY = minY
        self.contentMaxWidth = contentMaxWidth
        self.contentMinHeight = contentMinHeight
        self.paddingX = paddingX
        self.paddingY = paddingY
    }
}

final class EncryptTooltipNode: ASDisplayNode {
    init(config: EncryptTooltipRectConfig, text : String, font: UIFont? = nil) {
        super.init()
        self.setViewBlock {
            return EncryptTooltipView(config: config, text: text, font: font)
        }
    }
    
    public func update(minY: CGFloat) {
        (self.view as? EncryptTooltipView)?.update(minY: minY)
    }
}

final class EncryptTooltipView: UIView {
    private var roundedRect:CGRect = CGRect()
    private let tipWidth: CGFloat = 19.0
    private let tipHeight: CGFloat = 7.5
    private let tipOffset: CGFloat = 37.0
    
    private var paddingX: CGFloat = 16.0
    private var paddingY: CGFloat = 9.0
    private var contentWidth: CGFloat = 191.0
    private var contentHeight: CGFloat = 20.0
    private let imageWidth: CGFloat = 9.0
    private let imageHeight: CGFloat = 12.0
    private let gap: CGFloat = 6.0
    private var font: UIFont = UIFont.systemFont(ofSize: 15)
    
    override private init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(config: EncryptTooltipRectConfig, text : String, font: UIFont? = nil) {
        self.init(frame: CGRect())
        self.setup(config: config, text : text, font: font)
    }
    
    public func update(minY: CGFloat) {
        let origin = CGPoint(x: self.frame.origin.x, y: minY)
        self.frame.origin = origin
    }
    
    private func setup(config: EncryptTooltipRectConfig, text : String, font: UIFont?) {
        self.contentMode = .redraw
        if let font = font {
            self.font = font
        }
        if let paddingX = config.paddingX {
            self.paddingX = paddingX
        }
        if let paddingY = config.paddingY {
            self.paddingY = paddingY
        }
        let textMaxWidth = config.contentMaxWidth - imageWidth - gap
        let preferredTextSize = CGSize(width: textMaxWidth, height: config.contentMinHeight)
        let estimateTextRect = text.estimateFrame(preferredSize: preferredTextSize, font: self.font)
        let textWidth = estimateTextRect.width > textMaxWidth ? textMaxWidth : estimateTextRect.width
        let textHeight = estimateTextRect.height < config.contentMinHeight ? config.contentMinHeight : estimateTextRect.height
        self.contentWidth = textWidth + imageWidth + gap
        self.contentHeight = textHeight
        let size = CGSize(width: self.contentWidth + self.paddingX*2, height: self.contentHeight + self.paddingY*2 + self.tipHeight)
        let origin = CGPoint(x: config.maxX - size.width, y: config.minY)
        self.frame = CGRect(origin: origin, size: size)
        self.isHidden = false
        self.createContent(text)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        drawToolTip(rect)
    }
    
    private func drawToolTip(_ rect : CGRect) {
        roundedRect = CGRect(x: rect.minX, y: rect.minY + tipHeight, width: rect.width, height: rect.height - tipHeight)
        let roundedRectPath = UIBezierPath(roundedRect: roundedRect, cornerRadius: 14.0)
        let trianglePath = createTipPath()
        roundedRectPath.append(trianglePath)
        let shape = createShapeLayer(roundedRectPath.cgPath)
        self.layer.insertSublayer(shape, at: 0)
    }
    
    private func createTipPath() -> UIBezierPath {
        let tipRect = CGRect(x: tipX, y: tipY, width: tipWidth, height: tipHeight)
        let trianglePath = UIBezierPath()
        trianglePath.move(to: CGPoint(x: tipRect.minX, y: tipRect.maxY))
        trianglePath.addLine(to: CGPoint(x: tipRect.midX, y: tipRect.minY))
        trianglePath.addLine(to: CGPoint(x: tipRect.maxX, y: tipRect.maxY))
        trianglePath.addLine(to: CGPoint(x: tipRect.minX, y: tipRect.maxY))
        trianglePath.close()
        return trianglePath
    }
    
    private func createShapeLayer(_ path : CGPath) -> CAShapeLayer{
        let shape = CAShapeLayer()
        shape.path = path
        shape.fillColor = UIColor.white.cgColor
        shape.opacity = 0.25
        shape.compositingFilter = "overlayBlendMode"
        return shape
    }
    
    private var tipX: CGFloat {
        roundedRect.maxX - tipOffset - tipWidth
    }
    
    private var tipY: CGFloat {
        roundedRect.minY - tipHeight
    }
    
    private func createContent(_ text : String) {
        let container = UIView(frame: CGRect(x: 0, y: tipHeight, width: contentWidth, height: contentHeight))
        addImageView(container: container)
        addLabel(container: container, text: text)
        container.center = CGPoint(x: self.bounds.midX, y: self.bounds.height/2 + tipHeight/2)
        addSubview(container)
    }
    
    private func addImageView(container: UIView) {
        let image = UIImage(bundleImageName: "Chat/Input/Accessory Panels/TextLockIcon")?.withRenderingMode(.alwaysTemplate)
        let y = container.bounds.midY - imageHeight/2
        let imageView = UIImageView(frame: CGRect(x: 0, y: y, width: imageWidth, height: imageHeight))
        imageView.image = image
        imageView.tintColor = .white
        imageView.contentMode = .scaleToFill
        container.addSubview(imageView)
    }
    
    private func addLabel(container: UIView, text : String) {
        let offsetLeft = imageWidth + gap
        let label = UILabel(frame: CGRect(x: offsetLeft, y: 0, width: container.bounds.width - offsetLeft, height: container.bounds.height))
        label.font = self.font
        label.text = text
        label.textColor = .white
        container.addSubview(label)
    }
}
