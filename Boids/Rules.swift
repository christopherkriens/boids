import UIKit

/**
 Rule protocol
 - All rules must conform to this basic protocol
 */
protocol Rule {
    var weight: CGFloat { get set }
    mutating func apply(toBoid boid:Boid, inFlock flock:[Boid])
}


/**
 Center of Mass
 
 - This rule applies a tendency to move the boid
 toward the averaged position of the entire flock
 */
struct CenterOfMass: Rule {
    var weight: CGFloat = 1.0
    var factor: CGFloat = 300
    
    mutating func apply(toBoid boid:Boid, inFlock flock:[Boid]) {
        for flockBoid in flock {
            guard flockBoid != boid else { continue }
            boid.velocity += flockBoid.position
        }
        boid.velocity /= CGFloat(flock.count-1)
        boid.velocity = (boid.velocity - boid.position) / factor
    }
}


/**
 Separation
 
 - This rule applies a tendency to move away from 
 neighboring boids when they get too close together
 */
struct Separation: Rule {
    var weight: CGFloat = 1.0
    
    private let personalSpace: CGFloat = 25.0

    mutating func apply(toBoid boid:Boid, inFlock flock:[Boid]) {
        for flockBoid in flock {
            guard flockBoid != boid else { continue }
            
            if boid.position.distance(from: flockBoid.position) < self.personalSpace {
                boid.velocity -= flockBoid.position - boid.velocity
                print("too close")
            }
        }
    }
}

/**
 Alignment
 
 - This rule applies a tendency for a boid to align its
 direction with the average direction of the entire flock
 */
struct Alignment: Rule {
    var weight: CGFloat = 1.0
    
    mutating func apply(toBoid boid:Boid, inFlock flock:[Boid]) {
        for flockBoid in flock {
            guard flockBoid != boid else { continue }
            boid.velocity += flockBoid.velocity
        }
        boid.velocity /= CGFloat(flock.count-1)
        boid.velocity += (boid.velocity - boid.velocity)
    }
}
