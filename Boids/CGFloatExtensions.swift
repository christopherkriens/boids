import CoreGraphics

public extension CGFloat {
    var degreesToRadians: CGFloat {
        return self * .pi / 180
    }

    var radiansToDegrees: CGFloat {
        return self * 180 / .pi
    }
}
