import Foundation
import UIKit
import Display
import AsyncDisplayKit
import CallsEmoji

private let labelFont = Font.regular(22.0)
private let animationNodesCount = 3

private class EmojiSlotNode: ASDisplayNode {
    var emoji: String = "" {
        didSet {
            self.node.attributedText = NSAttributedString(string: emoji, font: labelFont, textColor: .black)
            let _ = self.node.updateLayout(CGSize(width: 100.0, height: 100.0))
        }
    }
    
    private let maskNode: ASDisplayNode
    private let containerNode: ASDisplayNode
    private let node: ImmediateTextNode
    private let animationNodes: [ImmediateTextNode]
    
    override init() {
        self.maskNode = ASDisplayNode()
        self.containerNode = ASDisplayNode()
        self.node = ImmediateTextNode()
        self.animationNodes = (0 ..< animationNodesCount).map { _ in ImmediateTextNode() }
                    
        super.init()
        
        let maskLayer = CAGradientLayer()
        maskLayer.colors = [UIColor.clear.cgColor, UIColor.white.cgColor, UIColor.white.cgColor, UIColor.clear.cgColor]
        maskLayer.locations = [0.0, 0.2, 0.8, 1.0]
        maskLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        maskLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        self.maskNode.layer.mask = maskLayer
        
        self.addSubnode(self.containerNode)
        self.containerNode.addSubnode(self.node)
    }
    
    func animateIn(duration: Double, reverseIndex: Int) {
        self.containerNode.layer.animatePosition(from: CGPoint(x: -CGFloat(reverseIndex)*self.bounds.width/2 + 5, y: 0), to: CGPoint(), duration: duration, delay: 0.1, timingFunction: kCAMediaTimingFunctionSpring, additive: true)
    }
    
    override func layout() {
        super.layout()
        
        let maskInset: CGFloat = 4.0
        let maskFrame = self.bounds.insetBy(dx: 0.0, dy: -maskInset)
        self.maskNode.frame = maskFrame
        self.maskNode.layer.mask?.frame = CGRect(origin: CGPoint(), size: maskFrame.size)
        
        let spacing: CGFloat = 2.0
        let containerSize = self.bounds.size
        self.containerNode.frame = CGRect(origin: CGPoint(x: 0.0, y: maskInset), size: containerSize)
        
        self.node.frame = CGRect(origin: CGPoint(), size: self.bounds.size)
        var offset: CGFloat = self.bounds.height + spacing
        for node in self.animationNodes {
            node.frame = CGRect(origin: CGPoint(x: 0.0, y: offset), size: self.bounds.size)
            offset += self.bounds.height + spacing
        }
    }
}

final class CallControllerKeyButton: HighlightableButtonNode {
    private let containerNode: ASDisplayNode
    private let nodes: [EmojiSlotNode]
    
    var key: String = "" {
        didSet {
            var index = 0
            for emoji in self.key {
                guard index < 4 else {
                    return
                }
                self.nodes[index].emoji = String(emoji)
                index += 1
            }
        }
    }
    
    init() {
        self.containerNode = ASDisplayNode()
        self.nodes = (0 ..< 4).map { _ in EmojiSlotNode() }
       
        super.init(pointerStyle: nil)
        
        self.addSubnode(self.containerNode)
        self.nodes.forEach({ self.containerNode.addSubnode($0) })
    }
        
    func animateIn() {
        self.layoutIfNeeded()
        self.containerNode.layer.animateAlpha(from: 0.0, to: 1.0, duration: 0.5)
        
        let initDuration: Double = 0.2
        for (index, node) in self.nodes.enumerated() {
            let reverseIndex = abs(index - 4)
            let duration = initDuration + 0.1 * Double(reverseIndex)
            
            node.animateIn(duration: duration, reverseIndex: reverseIndex)
        }
    }
    
    override func measure(_ constrainedSize: CGSize) -> CGSize {
        return CGSize(width: 114.0, height: 26.0)
    }
    
    override func layout() {
        super.layout()
        
        self.containerNode.frame = self.bounds
        var index = 0
        let nodeSize = CGSize(width: 29.0, height: self.bounds.size.height)
        for node in self.nodes {
            node.frame = CGRect(origin: CGPoint(x: CGFloat(index) * nodeSize.width, y: 0.0), size: nodeSize)
            index += 1
        }
    }
}
