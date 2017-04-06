import UIKit

/**
 Rule protocol
 - All rules must conform to this basic protocol
 */
protocol Rule {
    var velocity: CGPoint { get }
    mutating func apply(toBoid boid:Boid, inFlock flock:[Boid])
}


/**
 Center of Mass
 
 - This rule applies a tendency to move the boid
 toward the averaged position of the entire flock
 */
class CenterOfMass: Rule {
    var factor: CGFloat = 300
    var velocity: CGPoint = CGPoint.zero
    
    func apply(toBoid boid:Boid, inFlock flock:[Boid]) {
        self.velocity = CGPoint.zero

        for flockBoid in flock {
            guard flockBoid != boid else { continue }
            self.velocity += flockBoid.position
        }
        self.velocity /= CGFloat(flock.count-1)
        self.velocity = (self.velocity - boid.position) / 100
    }
}


/**
 Separation
 
 - This rule applies a tendency to move away from 
 neighboring boids when they get too close together
 */
class Separation: Rule {
    var velocity: CGPoint = CGPoint.zero
    private let personalSpace: CGFloat = 25.0

    func apply(toBoid boid:Boid, inFlock flock:[Boid]) {
        self.velocity = CGPoint.zero
        
        for flockBoid in flock {
            guard flockBoid != boid else { continue }
            
            if boid.position.distance(from: flockBoid.position) < self.personalSpace {
                self.velocity -= (flockBoid.position - boid.position)/25
            }
        }
    }
}

/**
 Alignment
 
 - This rule applies a tendency for a boid to align its
 direction with the average direction of the entire flock
 */
class Alignment: Rule {
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
