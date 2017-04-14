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
    var goals = [Goal]()
    var destination = CGPoint.zero
    
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
        self.goals.append(Seek(intensity: 0.9))
    }
    
    func evade(from point:CGPoint) {
        self.destination = point
        self.goals.append(Evade(intensity: 0.9))
    }

    func updateBoid(withinFlock flock: [Boid], frame: CGRect) {
        let neighbors = self.findNeighbors(inFlock: flock)
        
        if neighbors.count > 1 {
            self.perceivedDirection = (neighbors.reduce(CGPoint.zero) { $0 + $1.velocity }) / CGFloat(neighbors.count)
            self.perceivedCenter = (neighbors.reduce(CGPoint.zero) { $0 + $1.position }) / CGFloat(neighbors.count)
            self.currentSpeed = maximumFlockSpeed
            
        } else {
            self.perceivedCenter = (flock.reduce(CGPoint.zero) { $0 + $1.position }) / CGFloat(flock.count)
            self.perceivedCenter -= self.position / CGFloat(flock.count)
            
            self.perceivedDirection = (flock.reduce(CGPoint.zero) { $0 + $1.velocity }) / CGFloat(flock.count)
            self.perceivedDirection -= (self.velocity / CGFloat(flock.count))

            // experimental! accelerate when boid is outside of any group
            // they should want to return toward the average group quickly
            if (self.currentSpeed < self.maximumFlockSpeed+1) {
                self.currentSpeed *= 1.1
            }
        }

        //** Apply each of the boid's behaviors **//
        for behavior in self.behaviors {
            let behaviorClass = String(describing: type(of: behavior))
    
            switch behaviorClass {
            case String(describing: Cohesion.self):
                let cohension = behavior as? Cohesion
                cohension?.apply(toBoid: self, inFlock: flock, withCenterOfMass:self.perceivedCenter)
                
            case String(describing: Separation.self):
                let separation = behavior as? Separation
                separation?.apply(toBoid: self, inFlock: flock)
                
            case String(describing: Alignment.self):
                let alignment = behavior as? Alignment
                alignment?.apply(toBoid: self, inFlock: flock, withAlignment: self.perceivedDirection)
                
            case String(describing: Bound.self):
                let bound = behavior as? Bound
                bound?.apply(toBoid: self, inFrame: frame)
                
            default: break
            }
        }
        
        //** Apply each of the boid's goals **//
        for goal in self.goals {
            let goalClass = String(describing: type(of: goal))

            switch goalClass {
            case String(describing: Seek.self):
                let seek = goal as? Seek
                seek?.move(boid: self, toPoint: self.destination)
            case String(describing: Evade.self):
                let evade = goal as? Evade
                evade?.move(boid: self, fromPoint: self.destination)
                
            default: break
            }
        }

        self.updatePosition(frame: frame)
    }
}


// MARK: - Private
fileprivate extension Boid {
    
    func updatePosition(frame: CGRect) {
        let momentum: CGFloat = 5
        
        //** Goals take priority over flocking behaviors **//
        if self.goals.count > 0 {
            //*** Move toward the average destination of all goals ***//
            self.velocity += (self.goals.reduce(self.velocity) { $0 + $1.scaledVelocity }) / momentum
        } else {
            //*** Move the average velocity from each of the behaviors ***//
            self.velocity += (self.behaviors.reduce(self.velocity) { $0 + $1.scaledVelocity }) / momentum
        }
        
        // Limit the maximum velocity per update
        applySpeedLimit()
        
        // Stay rotated toward the direction of travel
        rotate()
        
        self.position += self.velocity
    }
    
    func applySpeedLimit() {
        if self.goals.count > 0 {
            currentSpeed = maximumGoalSpeed
        }
        
        let vector = self.velocity.length
        if (vector > self.currentSpeed) {
            let unitVector = self.velocity / vector
            self.velocity = unitVector * self.currentSpeed
        }
    }
    
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
        let currentIdealDirection = CGFloat(-atan2(Double(velocity.x), Double(velocity.y)))
        self.zRotation = currentIdealDirection + CGFloat(GLKMathDegreesToRadians(90))
        
        // flipping functionality; gets weird when moving vertically so disabled
        /*  if self.velocity.x < 0 {
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

