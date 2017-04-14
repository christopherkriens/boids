//
//  Boid.swift
//  Boids 🐠🐠🐠
//
//  Created by Christopher Kriens on 4/5/17.
//
//

import SpriteKit

class Boid: SKSpriteNode {
    var maximumFlockSpeed: CGFloat = 2
    var maximumGoalSpeed: CGFloat = 4
    var currentSpeed: CGFloat
    var velocity = CGPoint.zero
    var behaviors = [Behavior]()
    var destination = CGPoint.zero
    let momentum: CGFloat = 5
    
    let visionAngle: CGFloat = 180
    
    private var timer: Timer?
    private var perceivedCenter = CGPoint.zero
    private var perceivedDirection = CGPoint.zero
    
    var radius: CGFloat = 0
    var neighborhoodSize:CGFloat = 0

    
    // MARK: - Initialization

    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        self.currentSpeed = maximumFlockSpeed

        super.init(texture: texture, color: color, size: size)

        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.position = CGPoint.zero
        self.zPosition = 2
        self.name = "boid"

        self.behaviors = [Cohesion(intensity: 0.01), Separation(intensity: 0.02), Alignment(intensity: 0.1), Bound(intensity:1.0)]
        self.radius = min(self.size.width, self.size.height)
        self.neighborhoodSize = self.radius * 4
        
        // Possible enhancement; Modify the local boid's perception of the flock to
        // remove himself from it.  This way we don't always have to consider it.
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Updates
    
    func seek(to point:CGPoint) {
        self.destination = point
        self.behaviors.append(Seek(intensity: 0.9))
    }
    
    func evade(from point:CGPoint) {
        self.destination = point
        self.behaviors.append(Evade(intensity: 0.9))
    }

    func updateBoid(withinFlock flock: [Boid], frame: CGRect) {
        let neighborhood = self.findNeighbors(inFlock: flock)
        
        // Update this boid's flock perception within its neighborhood
        if neighborhood.count > 1 {
            self.perceivedDirection = (neighborhood.reduce(CGPoint.zero) { $0 + $1.velocity }) / CGFloat(neighborhood.count)
            self.perceivedCenter = (neighborhood.reduce(CGPoint.zero) { $0 + $1.position }) / CGFloat(neighborhood.count)
            self.currentSpeed = maximumFlockSpeed

        // Boid is on its own and has no neighbors..
        } else {
            self.perceivedCenter = (flock.reduce(CGPoint.zero) { $0 + $1.position }) / CGFloat(flock.count)
            self.perceivedCenter -= self.position / CGFloat(flock.count)

            self.perceivedDirection = (flock.reduce(CGPoint.zero) { $0 + $1.velocity }) / CGFloat(flock.count)
            self.perceivedDirection -= (self.velocity / CGFloat(flock.count))

            //self.behaviors.append(Panic(intensity: 1.0))
        }

        // Apply each of the boid's behaviors
        for behavior in self.behaviors {
            let behaviorClass = String(describing: type(of: behavior))
            
            switch behaviorClass {
            case String(describing: Cohesion.self):
                let cohension = behavior as? Cohesion
                cohension?.apply(toBoid: self, withCenterOfMass:self.perceivedCenter)
                
            case String(describing: Separation.self):
                let separation = behavior as? Separation
                separation?.apply(toBoid: self, inFlock: neighborhood)
                
            case String(describing: Alignment.self):
                let alignment = behavior as? Alignment
                alignment?.apply(toBoid: self, withAlignment: self.perceivedDirection)
                
            case String(describing: Bound.self):
                let bound = behavior as? Bound
                bound?.apply(toBoid: self, inFrame: frame)
                
            case String(describing: Seek.self):
                let seek = behavior as? Seek
                seek?.apply(boid: self, withPoint: self.destination)
                
            case String(describing: Evade.self):
                let evade = behavior as? Evade
                evade?.apply(boid: self, withPoint: self.destination)
                
            default: break
            }
        }
        
        // Sum the velocities provided by each of the behaviors
        self.velocity += (self.behaviors.reduce(self.velocity) { $0 + $1.scaledVelocity }) / self.momentum
        
        // Limit the maximum velocity per update
        applySpeedLimit()
        
        // Stay rotated toward the direction of travel
        rotate()
        
        // Update the position
        self.position += self.velocity
    }
}


// MARK: - Private
fileprivate extension Boid {
    
    /**
     Applies the boid's current speed limit to its velocity
    */
    func applySpeedLimit() {
        let vector = self.velocity.length
        if (vector > self.currentSpeed) {
            let unitVector = self.velocity / vector
            self.velocity = unitVector * self.currentSpeed
        }
    }
    
    /**
     Examines an array of boids and returns a subarray with boids that are considered neighbors.
     - parameters:
        - inFlock: The array of boids for which potential neighbors can be found.
     - returns: A subarray with boids that are considered neighbors.  Current boid will never be included.
     */
    func findNeighbors(inFlock flock:[Boid]) -> [Boid] {
        var neighbors = [Boid]()
        
        for flockBoid in flock {
            guard flockBoid != self else { continue }
            if self.neighbors(boid: flockBoid) {
                neighbors.append(flockBoid)
            }
        }
        return neighbors
    }
    
    /**
     A boid considers another boid a neighbor if it is within a certain 
     distance and is able to perceive it within a 180º field of vison.
     - parameters:
        - boid: A boid to test against
     - returns: `Bool` - Whether or not this boid is a neighbor to the provided boid.
     */
    func neighbors(boid: Boid) -> Bool {
        if self.position.distance(from: boid.position) < self.neighborhoodSize {
            let lowerBound = boid.velocity.rotate(aroundOrigin: boid.position, byDegrees: -self.visionAngle/2)
            let upperBound = boid.velocity.rotate(aroundOrigin: boid.position, byDegrees: self.visionAngle/2)
            
            if (lowerBound*boid.velocity) * (lowerBound*upperBound) >= 0 && (upperBound*boid.velocity) * (upperBound*lowerBound) >= 0 {
                return true
            }
        }
        return false
    }
    
    func rotate() {
        self.zRotation = CGFloat(-atan2(Double(velocity.x), Double(velocity.y))) + CGFloat(GLKMathDegreesToRadians(90))
        
        // flipping functionality; looks weird when moving vertically so disabled
        // considering some improvements
        /* if self.velocity.x < 0 {
            let flip = SKAction.scaleX(to: -1, duration: 0.05)
            self.setScale(1.0)
            self.run(flip)
            self.zRotation += CGFloat(GLKMathDegreesToRadians(180))
         } else {
            let flip = SKAction.scaleX(to: 1, duration: 0.1)
            self.setScale(1.0)
            self.run(flip)
         }*/
    }
}


extension Boid {
    override public var description: String {
        return "Boid<\(self.name ?? "")> | Position: \(self.position.x),\(self.position.y) | Velocity: \(self.velocity.x), \(self.velocity.y)"
    }
}

