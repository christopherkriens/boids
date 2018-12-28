import CoreGraphics

extension CGPoint {
    public func within(_ range: CGFloat, of point: CGPoint) -> Bool {
        return self.distance(from: point) <= range
    }

    public func outside(_ range: CGFloat, of point: CGPoint) -> Bool {
        return !(within(range, of: point))
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

    public func pointByRotatingAround(_ origin: CGPoint, byDegrees degrees: CGFloat) -> CGPoint {
        let dx = self.x - origin.x
        let dy = self.y - origin.y
        let radius = sqrt(dx * dx + dy * dy)
        let azimuth = atan2(dy, dx)
        let newAzimuth = azimuth + degrees.degreesToRadians
        let x = origin.x + radius * cos(newAzimuth)
        let y = origin.y + radius * sin(newAzimuth)
        return CGPoint(x: x, y: y)
    }

    public func distance(from point: CGPoint) -> CGFloat {
        return (self - point).length
    }

    public func squareDistance(from point: CGPoint) -> CGFloat {
        return (self - point).squareLength
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
