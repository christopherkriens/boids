//
//  Boid.swift
//  Boids
//
//    🐠
//  🐠
//   🐠
//
//  Created by Christopher Kriens on 4/5/17.

import SpriteKit

class Boid: SKSpriteNode {
    var maximumFlockSpeed: CGFloat = 2
    var maximumGoalSpeed: CGFloat = 4
    var currentSpeed: CGFloat = 2
    var velocity = CGPoint.zero
    var sceneFrame = CGRect.zero
    var behaviors = [Behavior]()
    
    let momentum: CGFloat = 5
    let visionAngle: CGFloat = 180
    
    private var perceivedCenter = CGPoint.zero
    private var perceivedDirection = CGPoint.zero
    
    lazy var radius: CGFloat = {
        return min(self.size.width, self.size.height)
    }()
    
    lazy var neighborhoodSize:CGFloat = {
        return self.radius * 4
    }()

    
    // MARK: - Initialization
    
    init(withCharacter character: Character = "❌", fontSize font:CGFloat = 36) {
        
        super.init(texture: nil, color: SKColor.clear, size: CGSize())
        
        // Configure SpriteNode properties
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.position = CGPoint.zero
        self.zPosition = 2
        self.name = "boid"
        
        // 🏷 Create the label and set the character and size
        let boidlabel = SKLabelNode(text: String(character))
        boidlabel.fontSize = font
        self.addChild(boidlabel)

        self.size = CGSize(width: boidlabel.fontSize, height: boidlabel.fontSize)
        self.behaviors = [Cohesion(intensity: 0.01), Separation(intensity: 0.02), Alignment(intensity: 0.15), Bound(intensity:0.4)]
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Updates

    func seek(_ point:CGPoint) {
        // 🗑 Remove any existing Seek behaviors
        self.behaviors = self.behaviors.filter() { !($0 is Seek) }
        
        self.behaviors.append(Seek(intensity: 0.2, point: point))
    }

    func evade(_ point:CGPoint) {
        // 🗑 Remove any existing Seek behaviors
        self.behaviors = self.behaviors.filter() { !($0 is Seek) }
        
        // ♻️ If there is an evade behavior in place, reuse it
        for thisBehavior in self.behaviors {
            if let evade = thisBehavior as? Evade {
                evade.point = point
                return
            }
        }
        self.behaviors.append(Evade(intensity: 0.8, point: point))
    }

    func updateBoid(inFlock flock: [Boid]) {
        let neighborhood = self.findNeighbors(inFlock: flock)
        
        // 🐠 Update this boid's flock perception within its neighborhood
        if neighborhood.count > 0 {
            self.perceivedDirection = (neighborhood.reduce(CGPoint.zero) { $0 + $1.velocity }) / CGFloat(neighborhood.count)
            self.perceivedCenter = (neighborhood.reduce(CGPoint.zero) { $0 + $1.position }) / CGFloat(neighborhood.count)
            self.currentSpeed = maximumFlockSpeed

        // 😭 Boid is on its own with no neighbors
        } else {
            if !self.behaviors.contains(where: { $0 is Rejoin }) {
                self.behaviors.append(Rejoin(intensity: 0.5))
            }
        }

        // ✏️ Apply each of the boid's behaviors
        for behavior in self.behaviors {
            let behaviorClass = String(describing: type(of: behavior))
            
            switch behaviorClass {
            case String(describing: Cohesion.self):
                if let cohension = behavior as? Cohesion {
                    cohension.apply(toBoid: self, withCenterOfMass:self.perceivedCenter)
                }
            case String(describing: Separation.self):
                if let separation = behavior as? Separation {
                    separation.apply(toBoid: self, inFlock: neighborhood)
                }
            case String(describing: Alignment.self):
                if let alignment = behavior as? Alignment {
                    alignment.apply(toBoid: self, withAlignment: self.perceivedDirection)
                }
            case String(describing: Bound.self):
                if let bound = behavior as? Bound {
                    if let frame = self.parent?.frame {
                        bound.apply(toBoid: self, inFrame: frame)
                    }
                }
            case String(describing: Seek.self):
                if let seek = behavior as? Seek {
                    seek.apply(boid: self)
                }
            case String(describing: Evade.self):
                if let evade = behavior as? Evade {
                    evade.apply(boid: self)
                }
            case String(describing: Rejoin.self):
                if let panic = behavior as? Rejoin {
                    panic.apply(boid:self, neighbors:neighborhood, nearestNeighbor: nearestNeighbor(flock: flock))
                }
            default: break
            }
        }

        // 📝 Sum the velocities provided by each of the behaviors
        self.velocity += (self.behaviors.reduce(self.velocity) { $0 + $1.scaledVelocity }) / self.momentum
        
        // 🚧 Limit the maximum velocity per update
        applySpeedLimit()
        
        // 🔺 Stay rotated toward the direction of travel
        rotate()
        
        // 📍 Update the position on screen
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
            let lowerBound = boid.velocity.pointByRotatingAround(boid.position, byDegrees: -self.visionAngle/2)
            let upperBound = boid.velocity.pointByRotatingAround(boid.position, byDegrees: self.visionAngle/2)
           
            if (lowerBound*boid.velocity) * (lowerBound*upperBound) >= 0 && (upperBound*boid.velocity) * (upperBound*lowerBound) >= 0 {
                return true
            }
        }
        return false
    }

    /**
     Finds the boid with the closest position within the given flock.
     - parameters:
        - flock: A flock of boids to search
     - returns: `Boid?` - The closest boid.  Can be nil.
     */
    func nearestNeighbor(flock: [Boid]) -> Boid? {
        guard var nearestBoid = flock.first else {
            return nil
        }
        
        for flockBoid in flock {
            if self.position.distance(from: flockBoid.position) < self.position.distance(from: nearestBoid.position) {
                nearestBoid = flockBoid
            }
        }
        return nearestBoid
    }

    func rotate() {
        self.zRotation = CGFloat(-atan2(Double(velocity.x), Double(velocity.y))) - CGFloat(90).degreesToRadians
    }
}
