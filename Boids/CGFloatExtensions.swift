import CoreGraphics

public extension CGFloat {
    var degreesToRadians: CGFloat {
        return self * .pi / 180
    }
    
    var radiansToDegrees: CGFloat {
        return self * 180 / .pi
    }
    
    public static func random(min: CGFloat, max: CGFloat) -> CGFloat {
        assert(min < max)
        return CGFloat.random() * (max - min) + min
    }
    
    public static func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
}
