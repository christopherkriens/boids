import UIKit
import GameplayKit

// Algorithm : http://www.kfish.org/boids/pseudocode.html

/**
 Behavior protocol
 - All behaviors must adopt this protocol
 **/
protocol Behavior {
    var velocity: CGPoint { get }
    var intensity: CGFloat { get set }
    init(intensity: CGFloat)
}

class GenericBehavior: Behavior {
    var intensity: CGFloat
    var velocity: CGPoint
    let valid: ClosedRange<CGFloat> = 0.0...1.0
    
    required init(intensity: CGFloat) {
        self.velocity = CGPoint.zero

        guard valid.contains(intensity) else {
            self.intensity = (round(intensity) > valid.upperBound/2) ? valid.lowerBound : valid.upperBound
            return
        }
        self.intensity = intensity
    }
    
    convenience init() {
        self.init(intensity: 1)
    }
}

/**
 Cohesion
 
 - This behavior applies a tendency to move the boid
 toward the averaged position of the entire flock
 **/
final class Cohesion: GenericBehavior {
    
    func apply(toBoid boid:Boid, inFlock flock:[Boid], withCenterOfMass centerOfMass: CGPoint) {
        self.velocity = centerOfMass
        self.velocity = (self.velocity - boid.position) * self.intensity
    }
}

/**
 Separation
 
 - This behavior applies a tendency to move away from
 neighboring boids when they get too close together
 **/
final class Separation: GenericBehavior {

    func apply(toBoid boid:Boid, inFlock flock:[Boid]) {
        self.velocity = CGPoint.zero
        
        for flockBoid in flock {
            guard flockBoid != boid else { continue }
            
            if boid.position.distance(from: flockBoid.position) < boid.radius {
                self.velocity -= (flockBoid.position - boid.position) * self.intensity
            }
        }
    }
}

/**
 Alignment
 
 - This behavior applies a tendency for a boid to align its
 direction with the average direction of the entire flock
 **/
final class Alignment: GenericBehavior {
    func apply(toBoid boid:Boid, inFlock flock:[Boid], withAlignment alignment: CGPoint) {
        self.velocity = alignment
        self.velocity += (self.velocity - boid.velocity) * self.intensity
    }
}

/**
 Bound
 
 - This behavior applies a tendency for a boid to move away 
 from the edges of the screen within a sufficient margin
 **/
final class Bound: GenericBehavior {
    func apply(toBoid boid:Boid, inFrame frame: CGRect) {
        self.velocity = CGPoint.zero

        let borderMargin:CGFloat = 100
        let borderAversion: CGFloat = 2

        let xMinimum = borderMargin
        let yMinimum = borderMargin
        let xMaximum = frame.size.width - borderMargin
        let yMaximum = frame.size.height - borderMargin
        
        if boid.position.x < xMinimum {
            self.velocity.x += borderAversion
        }
        if boid.position.x > xMaximum {
            self.velocity.x -= borderAversion
        }
        
        if boid.position.y < yMinimum {
            self.velocity.y += borderAversion
        }
        if boid.position.y > yMaximum {
            self.velocity.y -= borderAversion
        }
    }
}
