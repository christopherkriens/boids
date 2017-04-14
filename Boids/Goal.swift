import UIKit
import GameplayKit


/**
 Goal protocol
 - All goals must adopt this protocol
 **/
protocol Goal {
    /// The result velocity after the calculation
    var velocity: CGPoint { get set }
    
    /// The intensity applied to the velocity, bounded 0.0 to 1.0
    var intensity: CGFloat { get set }

    init(intensity: CGFloat)
    init()
}

extension Goal {
    init(intensity: CGFloat) {
        self.init()
        
        self.velocity = CGPoint.zero
        self.intensity = intensity
        
        let valid: ClosedRange<CGFloat> = 0.0...1.0
        guard valid.contains(intensity) else {
            self.intensity = (round(intensity) > valid.upperBound/2) ? valid.lowerBound : valid.upperBound
            return
        }
    }
    
    var scaledVelocity: CGPoint {
        return velocity*intensity
    }
}


/**
 Seek
 
 - This moves the boid toward a point in the frame
 **/
final class Seek: Goal {
    var intensity: CGFloat = 0.0
    var velocity: CGPoint = CGPoint.zero
    
    func move(boid:Boid, toPoint destination:CGPoint) {
        let goalThreshhold: CGFloat = boid.radius
        
        guard !boid.position.nearlyEqual(to: destination, epsilon: goalThreshhold) else {
            boid.currentSpeed = boid.maximumFlockSpeed
            boid.goals = boid.goals.filter() { $0 as? Seek !== self }
            return
        }
        self.velocity = (destination - boid.position) * self.intensity
    }
}

/**
 Evade
 
 - This moves the boid away from a point in the frame
 **/
final class Evade: Goal {
    var intensity: CGFloat = 0.0
    var velocity: CGPoint = CGPoint.zero
    
    func move(boid:Boid, fromPoint destination:CGPoint) {
        let fearThreshold: CGFloat = boid.radius * 4

        if boid.position.nearlyEqual(to: destination, epsilon: fearThreshold) {
            self.velocity = -(destination - boid.position) / 10
        } else {
            boid.goals = boid.goals.filter() { $0 as? Evade !== self }
        }
    }
}
