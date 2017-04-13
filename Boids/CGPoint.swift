import CoreGraphics

extension CGPoint {
    public func nearlyEqual(to point: CGPoint, epsilon: CGFloat) -> Bool {
        let difference = self - point
        return fabs(difference.x) < epsilon && fabs(difference.y) < epsilon
    }
    
    public var length: CGFloat {
        return sqrt(squareLength)
    }
    
    public var squareLength: CGFloat {
        return x * x + y * y
    }
    
    public var unit: CGPoint {
        return self * (1.0 / length)
    }
    
    public var phase: CGFloat {
        return atan2(y, x)
    }
    
    public func rotate(aroundOrigin origin: CGPoint, byDegrees degrees: CGFloat) -> CGPoint {
        let dx = self.x - origin.x
        let dy = self.y - origin.y
        let radius = sqrt(dx * dx + dy * dy)
        let azimuth = atan2(dy, dx)
        let newAzimuth = azimuth + degrees.degreesToRadians
        let x = origin.x + radius * CoreGraphics.cos(newAzimuth)
        let y = origin.y + radius * CoreGraphics.sin(newAzimuth)
        return CGPoint(x: x, y: y)
    }
    
    public func distance(from point: CGPoint) -> CGFloat {
        return (self - point).length
    }
    
    public func squareDistance(from point: CGPoint) -> CGFloat {
        return (self - point).squareLength
    }
    
    public func angle(from point: CGPoint) -> CGFloat {
        return acos(cos(angleFrom: point))
    }
    
    public func cos(angleFrom point: CGPoint) -> CGFloat {
        return fmin(fmax(self * point / sqrt(self.squareLength * point.squareLength), -1.0), 1.0)
    }
}

extension CGPoint: CustomStringConvertible {
    public var description: String {
        return "(\(x), \(y))"
    }
}

public prefix func + (value: CGPoint) -> CGPoint {
    return value
}

public prefix func - (value: CGPoint) -> CGPoint {
    return CGPoint(x: -value.x, y: -value.y)
}

public func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

public func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

public func * (left: CGPoint, right: CGPoint) -> CGFloat { // dot product
    return left.x * right.x + left.y * right.y
}

public func * (left: CGPoint, right: CGFloat) -> CGPoint {
    return CGPoint(x: left.x * right, y: left.y * right)
}

public func * (left: CGFloat, right: CGPoint) -> CGPoint {
    return CGPoint(x: right.x * left, y: right.y * left)
}

public func / (left: CGPoint, right: CGFloat) -> CGPoint {
    return CGPoint(x: left.x / right, y: left.y / right)
}

public func += (left: inout CGPoint, right: CGPoint) {
    left = left + right
}

public func -= (left: inout CGPoint, right: CGPoint) {
    left = left - right
}

public func *= (left: inout CGPoint, right: CGFloat) {
    left = left * right
}

public func /= (left: inout CGPoint, right: CGFloat) {
    left = left / right
}
