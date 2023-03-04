import CoreGraphics

extension CGPath {
    static func getRightCurvePath(startCenter: CGPoint, targetCenter: CGPoint) -> CGPath {
        let maxX = max(startCenter.x, targetCenter.x)
        let contsrolX = maxX
        let contsrolY = abs(targetCenter.y - startCenter.y)
        let controlPoint = CGPoint(x: contsrolX, y: contsrolY)
        let path = CGMutablePath()
        path.move(to: startCenter)
        path.addQuadCurve(to: targetCenter, control: controlPoint)
        return path
    }
}
