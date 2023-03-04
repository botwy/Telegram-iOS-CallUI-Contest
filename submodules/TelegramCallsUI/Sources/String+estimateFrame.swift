import UIKit

extension String {
    func estimateFrame(preferredSize: CGSize, font: UIFont, paragraph: NSMutableParagraphStyle? = nil) -> CGRect {
        let options: NSStringDrawingOptions = [.usesFontLeading, .usesLineFragmentOrigin]
        var attributes: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : font]
        if let paragraph = paragraph {
            attributes[NSAttributedString.Key.paragraphStyle] = paragraph
        }
        
        let frame = NSString(string: self).boundingRect(with: preferredSize, options: options, attributes: attributes, context: nil)
        
        return frame
    }
}
