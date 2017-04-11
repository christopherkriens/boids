import UIKit
import GameplayKit

// Algorithm : http://www.kfish.org/boids/pseudocode.html

/**
 Behavior protocol
 - All behaviors must adopt this protocol
 **/
protocol Behavior {
    var velocity: CGPoint { get }
}

/**
 Cohesion
 
 - This behavior applies a tendency to move the boid
 toward the averaged position of the entire flock
 **/
class Cohesion: Behavior {
    var velocity: CGPoint = CGPoint.zero

    func apply(toBoid boid:Boid, inFlock flock:[Boid], withCenterOfMass centerOfMass: CGPoint) {
        self.velocity = centerOfMass
        self.velocity = (self.velocity - boid.position) / 300
    }
}

/**
 Separation
 
 - This behavior applies a tendency to move away from
 neighboring boids when they get too close together
 **/
class Separation: Behavior {
    var velocity: CGPoint = CGPoint.zero

    func apply(toBoid boid:Boid, inFlock flock:[Boid]) {
        self.velocity = CGPoint.zero
        
        for flockBoid in flock {
            guard flockBoid != boid else { continue }
            
            if boid.position.distance(from: flockBoid.position) < boid.radius {
                self.velocity -= (flockBoid.position - boid.position) / 20
            }
        }
    }
}

/**
 Alignment
 
 - This behavior applies a tendency for a boid to align its
 direction with the average direction of the entire flock
 **/
class Alignment: Behavior {
    var velocity: CGPoint = CGPoint.zero

    func apply(toBoid boid:Boid, inFlock flock:[Boid], withAlignment alignment: CGPoint) {
        self.velocity = alignment
        self.velocity += (self.velocity - boid.velocity) / 8
    }
}

/**
 Bound
 
 - This behavior applies a tendency for a boid to move away 
 from the edges of the screen within a sufficient margin
 **/
class Bound: Behavior {
    var velocity: CGPoint = CGPoint.zero

    func apply(toBoid boid:Boid, inFrame frame: CGRect) {
        self.velocity = CGPoint.zero

        let borderMargin:CGFloat = 100
        let borderTurnResistance: CGFloat = 2

        let xMinimum = borderMargin
        let yMinimum = borderMargin
        let xMaximum = frame.size.width - borderMargin
        let yMaximum = frame.size.height - borderMargin
        
        if boid.position.x < xMinimum {
            self.velocity.x += borderTurnResistance
        }
        if boid.position.x > xMaximum {
            self.velocity.x -= borderTurnResistance
        }
        
        if boid.position.y < yMinimum {
            self.velocity.y += borderTurnResistance
        }
        if boid.position.y > yMaximum {
            self.velocity.y -= borderTurnResistance
        }
    }
}
