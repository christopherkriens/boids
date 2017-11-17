import UIKit
import GameplayKit

// Core Behaviors Algorithm : http://www.kfish.org/boids/pseudocode.html

/**
 All behaviors must adopt this protocol.  Behaviors are expected to calculate
 a result vector based on the behavior rules and apply an intensity
 */
protocol Behavior: AnyObject {
    /// The result velocity after the calculation
    var velocity: CGPoint { get }
    
    /// The intensity applied to the velocity, bounded 0.0 to 1.0
    var intensity: CGFloat { get set }

    init(intensity: CGFloat)
    
    init()
}

/**
 This extension provides a default implementation for initialization, so
 that each class that adopts the protocol doesn't need to duplicate this
 common functionality, as well as a computed property for accessing the
 scaled vector.
 */
extension Behavior {
    init(intensity: CGFloat) {
        self.init()
        self.intensity = intensity

        // Make sure that intensity gets capped between 0 and 1
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
 This behavior applies a tendency to move the boid toward a position.
 This position tends to be the averaged position of the entire flock 
 or a smaller group.
 */
final class Cohesion: Behavior {
    var velocity: CGPoint = CGPoint.zero
    var intensity: CGFloat = 0.0

    func apply(toBoid boid:Boid, withCenterOfMass centerOfMass: CGPoint) {
        velocity = (centerOfMass - boid.position)
    }
}

/**
 This behavior applies a tendency to move away from neighbors when
 they get too close together.  Prevents the proclivity to stack up 
 on one another.
 */
final class Separation: Behavior {
    var velocity: CGPoint = CGPoint.zero
    var intensity: CGFloat = 0.0

    func apply(toBoid boid:Boid, inFlock flock:[Boid]) {
        velocity = CGPoint.zero

        for flockBoid in flock {
            guard flockBoid != boid else { continue }
            
            if boid.position.distance(from: flockBoid.position) < boid.radius*2 {
                let awayVector = (flockBoid.position - boid.position)
                velocity -= awayVector * (1/boid.position.distance(from: flockBoid.position))
            }
        }
    }
}

/**
 This behavior applies a tendency for a boid to align its
 direction with the average direction of the entire flock.
 */
final class Alignment: Behavior {
    var velocity: CGPoint = CGPoint.zero
    var intensity: CGFloat = 0.0

    func apply(toBoid boid:Boid, withAlignment alignment: CGPoint) {
        velocity = (alignment - boid.velocity)
    }
}

/**
 This behavior applies a tendency for a boid to move away
 from the edges of the screen within a configurable margin.
 */
final class Bound: Behavior {
    var velocity: CGPoint = CGPoint.zero
    var intensity: CGFloat = 0.0
    
    func apply(toBoid boid:Boid) {
        velocity = CGPoint.zero

        // Make sure each boid has a parent scene frame
        guard let frame = boid.parent?.frame else {
            return
        }
        
        let borderMargin:CGFloat = 100
        let borderAversion: CGFloat = boid.currentSpeed

        let horizontal = borderMargin...frame.size.width - borderMargin
        let vertical = borderMargin...frame.size.height - borderMargin
        
        if boid.position.x < horizontal.lowerBound {
            velocity.x += borderAversion
        }
        if boid.position.x > horizontal.upperBound {
            velocity.x -= borderAversion
        }
        
        if boid.position.y < vertical.lowerBound {
            velocity.y += borderAversion
        }
        if boid.position.y > vertical.upperBound {
            velocity.y -= borderAversion
        }
    }
}

/**
 This behavior applies a tendency for a boid to move toward a 
 particular point.  Seek is a temporary behavior that removes
 itself from the boid once the goal is reached.
 */
final class Seek: Behavior {
    var intensity: CGFloat = 0.0
    var velocity: CGPoint = CGPoint.zero
    var point: CGPoint = CGPoint.zero
    
    convenience init(intensity: CGFloat, point: CGPoint) {
        self.init(intensity: intensity)
        self.point = point
    }
    
    func apply(boid:Boid) {
        // Approximate touch size
        let goalThreshhold: CGFloat = 44.0
        
        // Remove this behavior once the goal has been reached
        guard boid.position.outside(goalThreshhold, of: point) else {
            boid.currentSpeed = boid.maximumFlockSpeed
            boid.behaviors = boid.behaviors.filter() { $0 as? Seek !== self }
            return
        }
        boid.currentSpeed = boid.maximumGoalSpeed
        velocity = (point - boid.position)
    }
}

/**
 This behavior applies a tendency for a boid to move away from
 a particular point.  Evade is a temporary behavior that
 removes itself from the boid once outside of `fearThreshold`.
 */
final class Evade: Behavior {
    var intensity: CGFloat = 0.0
    var velocity: CGPoint = CGPoint.zero
    var point: CGPoint = CGPoint.zero
    
    convenience init(intensity: CGFloat, point: CGPoint) {
        self.init(intensity: intensity)
        self.point = point
    }
    
    func apply(boid:Boid) {
        // Remove this behavior once the goal has been reached
        guard boid.position.within(boid.fearThreshold, of: point) else {
            boid.currentSpeed = boid.maximumFlockSpeed
            boid.behaviors = boid.behaviors.filter() { $0 as? Evade !== self }
            return
        }
        velocity = boid.position - point

        let multiplier: CGFloat = 150
        let distanceFromTouch = boid.position.distance(from: point)
        let evadeSpeed = boid.maximumGoalSpeed * (multiplier/distanceFromTouch)
        boid.currentSpeed = evadeSpeed < boid.maximumFlockSpeed ? boid.maximumFlockSpeed : evadeSpeed
    }
}
