import Foundation
import TelegramAnimatedStickerNode
import AnimatedStickerNode
import MediaResources
import TelegramCore
import AccountContext
import UIKit
import Display
import AsyncDisplayKit
import SwiftSignalKit
import LegacyComponents

final class EncryptKeyPreviewNode: ASDisplayNode {
    let keyTextNode: ASTextNode
    private var targetMinY: CGFloat = 0
    private let accountContext: AccountContext
    private var keyTextSize = CGSize()
    
    init(accountContext: AccountContext, keyText: String) {
        self.accountContext = accountContext
        self.keyTextNode = ASTextNode()
        self.keyTextNode.displaysAsynchronously = false
        
        super.init()
        
        self.keyTextNode.attributedText = NSAttributedString(string: keyText, attributes: [NSAttributedString.Key.font: Font.regular(48.0), NSAttributedString.Key.kern: 11.0 as NSNumber])
        self.keyTextSize = self.keyTextNode.measure(CGSize(width: 280.0, height: 48.0))
        // self.keyTextNode.attributedText = nil
        self.keyTextNode.frame = CGRect(origin: CGPoint(x: 0, y: self.targetMinY), size: keyTextSize)
        
        self.addSubnode(self.keyTextNode)
        for (index, char) in keyText.enumerated() {
            let emoji = String(char)
            var emojiFile: TelegramMediaFile?
            emojiFile = accountContext.animatedEmojiStickers[emoji]?.first?.file
            if emojiFile == nil {
                emojiFile = accountContext.animatedEmojiStickers[emoji.strippedEmoji]?.first?.file
            }
            if let emojiFile = emojiFile {
                self.setupAnimatedSticker(file: emojiFile, index: index)
            } else {
                let smile = ASTextNode()
                smile.attributedText = NSAttributedString(string: emoji, attributes: [NSAttributedString.Key.font: Font.regular(48.0), NSAttributedString.Key.kern: 11.0 as NSNumber])
                smile.frame = CGRect(x: index*48, y: 0, width: 48, height: 48)
                smile.displaysAsynchronously = false
                // self.keyTextNode.addSubnode(smile)
            }
        }
    }
    
    private func setupAnimatedSticker(file: TelegramMediaFile, index: Int) {
        //        let animationNode = DefaultAnimatedStickerNodeImpl()
        //        animationNode.setup(source: AnimatedStickerResourceSource(account: self.accountContext.account, resource: file.resource, fitzModifier: nil), width: 48, height: 48, playbackMode: .loop, mode: .direct(cachePathPrefix: nil))
        //        animationNode.visibility = true
        //        animationNode.displaysAsynchronously = false
        //        animationNode.frame = CGRect(x: index*48, y: 0, width: 48, height: 48)
        //        animationNode.updateLayout(size: CGSize(width: 48, height: 48))
        //        self.keyTextNode.addSubnode(animationNode)
    }
    
    func updateLayout(size: CGSize, transition: ContainedViewLayoutTransition) {
        transition.updateFrame(node: self.keyTextNode, frame: CGRect(origin: CGPoint(x: floor((size.width - self.keyTextSize.width) / 2) + 6.0, y: self.targetMinY), size: keyTextSize))
    }
    
    func setTargetMinY(_ minY: CGFloat) {
        self.targetMinY = minY
        let transition = ContainedViewLayoutTransition.immediate
        let origin = CGPoint(x: self.keyTextNode.frame.origin.x, y: minY)
        transition.updateFrame(node: self.keyTextNode, frame: CGRect(origin: origin, size: self.keyTextNode.frame.size))
    }
    
    func animateIn(from rect: CGRect, fromNode: ASDisplayNode) {
        self.keyTextNode.layer.animateAlpha(from: 0.0, to: 1.0, duration: 0.15)
        self.keyTextNode.layer.animateScale(from: rect.size.width / self.keyTextNode.frame.size.width, to: 1.0, duration: 0.5, timingFunction: CAMediaTimingFunctionName.easeOut.rawValue)
        
        let keyTextNodeAnimaton = CAKeyframeAnimation(keyPath: "position")
        keyTextNodeAnimaton.path = CGPath.getRightCurvePath(startCenter: CGPoint(x: rect.midX, y: rect.midY), targetCenter: self.keyTextNode.layer.position)
        self.keyTextNode.layer.add(keyTextNodeAnimaton, forKey: "position")
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        return nil
    }
}

