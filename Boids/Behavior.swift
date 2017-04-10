import UIKit
import GameplayKit

// Algorithm : http://www.kfish.org/boids/pseudocode.html

/**
 Behavior protocol
 - All behaviors must adopt this protocol
 */
protocol Behavior {
    var velocity: CGPoint { get }
}

/**
 Center of Mass
 
 - This rule applies a tendency to move the boid
 toward the averaged position of the entire flock
 */
class CenterOfMass: Behavior {
    var velocity: CGPoint = CGPoint.zero

    func apply(toBoid boid:Boid, inFlock flock:[Boid]) {
        self.velocity = CGPoint.zero

        for flockBoid in flock {
            guard flockBoid != boid else { continue }
            self.velocity += flockBoid.position
        }
        self.velocity /= CGFloat(flock.count-1)
        self.velocity = (self.velocity - boid.position) / 500
    }
}

/**
 Separation
 
 - This rule applies a tendency to move away from 
 neighboring boids when they get too close together
 */
class Separation: Behavior {
    var velocity: CGPoint = CGPoint.zero

    func apply(toBoid boid:Boid, inFlock flock:[Boid]) {
        self.velocity = CGPoint.zero
        
        for flockBoid in flock {
            guard flockBoid != boid else { continue }
            
            if boid.position.distance(from: flockBoid.position) < boid.radius {
                self.velocity -= (flockBoid.position - boid.position)/20
            }
        }
    }
}

/**
 Alignment
 
 - This rule applies a tendency for a boid to align its
 direction with the average direction of the entire flock
 */
class Alignment: Behavior {
    var velocity: CGPoint = CGPoint.zero

    func apply(toBoid boid:Boid, inFlock flock:[Boid]) {
        self.velocity = CGPoint.zero

        for flockBoid in flock {
            guard flockBoid != boid else { continue }
            self.velocity += flockBoid.velocity
        }
        self.velocity /= CGFloat(flock.count-1)
        
        self.velocity += (self.velocity - boid.velocity) / 8
    }
}
