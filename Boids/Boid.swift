//
//  Boid.swift
//  Boids
//
//     🐠 🐠
//  🐠 🐠  🐠
//    🐠 🐠 🐠
//
//  Created by Christopher Kriens on 4/5/17.

enum BoidOrientation: CGFloat {
    case north = 0
    case east = 270
    case south = 180
    case west = 90
}

import SpriteKit

class Boid: SKSpriteNode {
    var maximumFlockSpeed: CGFloat = 2
    var maximumGoalSpeed: CGFloat = 4
    var currentSpeed: CGFloat = 2
    var velocity = CGPoint.zero
    var behaviors = [Behavior]()
    let momentum: CGFloat = 6
    let visionAngle: CGFloat = 180
    
    fileprivate var sceneFrame = CGRect.zero
    fileprivate var neighborhood: [Boid] = [Boid]()
    fileprivate var orientation:BoidOrientation = .west
    fileprivate var perceivedCenter = CGPoint.zero
    fileprivate var perceivedDirection = CGPoint.zero
    
    lazy var radius: CGFloat = { return min(size.width, size.height) }()
    lazy var neighborhoodSize:CGFloat = { return radius * 4 }()

    
    // MARK: - Initialization
    
    public init(withCharacter character: Character = "❌", fontSize font: CGFloat = 36, orientation: BoidOrientation = .west) {
        
        super.init(texture: nil, color: SKColor.clear, size: CGSize())
        
        // Configure SpriteNode properties
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        position = CGPoint.zero
        zPosition = 2
        name = "boid"
        
        // Create the label and set the character and size
        let boidlabel = SKLabelNode(text: String(character))
        boidlabel.fontSize = font
        addChild(boidlabel)

        self.orientation = orientation
        size = CGSize(width: boidlabel.fontSize, height: boidlabel.fontSize)
        behaviors = [Cohesion(intensity: 0.01), Separation(intensity: 0.01), Alignment(intensity: 0.3), Bound(intensity:0.4)]
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Updates

    func seek(_ point:CGPoint) {
        // If there is a seek behavior in place, reuse it
        for thisBehavior in behaviors {
            if let seek = thisBehavior as? Seek {
                seek.point = point
                return
            }
        }
        behaviors.append(Seek(intensity: 0.03, point: point))
    }

    func evade(_ point:CGPoint) {
        // Remove any existing Bound and Seek behaviors
        behaviors = behaviors.filter() { !($0 is Seek) && !($0 is Bound) }
        
        // If there is an evade behavior in place, reuse it
        for thisBehavior in behaviors {
            if let evade = thisBehavior as? Evade {
                evade.point = point
                return
            }
        }
        behaviors.append(Evade(intensity: 0.2, point: point))
    }

    func evaluateNeighborhood(forFlock flock: [Boid]) {
        neighborhood = findNeighbors(inFlock: flock)
    }

    func updatePerception() {
        // Update this boid's flock perception within its neighborhood
        perceivedDirection = (neighborhood.reduce(CGPoint.zero) { $0 + $1.velocity }) / CGFloat(neighborhood.count)
        perceivedCenter = (neighborhood.reduce(CGPoint.zero) { $0 + $1.position }) / CGFloat(neighborhood.count)
    }

    func updateBoid(inFlock flock: [Boid], deltaTime: TimeInterval) {
        // Apply each of the boid's behaviors
        for behavior in behaviors {
            if let cohension = behavior as? Cohesion {
                cohension.apply(toBoid: self, withCenterOfMass:perceivedCenter)
                continue
            }
            if let separation = behavior as? Separation {
                separation.apply(toBoid: self, inFlock: neighborhood)
                continue
            }
            if let alignment = behavior as? Alignment {
                alignment.apply(toBoid: self, withAlignment: perceivedDirection)
                continue
            }
            if let bound = behavior as? Bound {
                bound.apply(toBoid: self)
                continue
            }
            if let seek = behavior as? Seek {
                seek.apply(boid: self)
                continue
            }
            if let evade = behavior as? Evade {
                evade.apply(boid: self)
                continue
            }
        }

        // Sum the velocities supplied by each of the behaviors
        velocity += behaviors.reduce(velocity) { $0 + $1.scaledVelocity } / momentum
        
        // Limit the maximum velocity per update
        applySpeedLimit()
        
        // Stay rotated toward the direction of travel
        rotate()
        
        // Update the position on screen
        position += velocity * (CGFloat(deltaTime) * 60)
    }
}


// MARK: - Private
fileprivate extension Boid {
    
    /**
     Applies the boid's current speed limit to its velocity
    */
    func applySpeedLimit() {
        let vector = velocity.length
        if (vector > currentSpeed) {
            let unitVector = velocity / vector
            velocity = unitVector * currentSpeed
        }
    }
    
    /**
     Examines an array of boids and returns a subarray with boids that are considered neighbors.
     This function is O(n²) where n = flock size and should be used sparingly for large flocks.
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
        
        // Boid is on its own with no neighbors, fall back to the flock
        guard neighbors.count > 0 else {
            return flock.filter() { $0 !== self }
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
        if position.distance(from: boid.position) < neighborhoodSize {
            let lowerBound = boid.velocity.pointByRotatingAround(boid.position, byDegrees: -visionAngle/2)
            let upperBound = boid.velocity.pointByRotatingAround(boid.position, byDegrees: visionAngle/2)
           
            if (lowerBound * boid.velocity) * (lowerBound * upperBound) >= 0 && (upperBound * boid.velocity) * (upperBound * lowerBound) >= 0 {
                return true
            }
        }
        return false
    }

    /**
     Finds the boid with the closest position within the given flock.  Does not account for vision.
     - parameters:
        - flock: A flock of boids to search
     - returns: `Boid?` - The closest boid.  Can be nil.
     */
    func nearestNeighbor(flock: [Boid]) -> Boid? {
        
        let flock = flock.filter() { $0 !== self }
        guard var nearestBoid = flock.first else {
            return nil
        }

        for flockBoid in flock {
            if position.distance(from: flockBoid.position) < position.distance(from: nearestBoid.position) {
                nearestBoid = flockBoid
            }
        }
        return nearestBoid
    }
    
    /**
     Rotates the sprite node so it's oriented in the direction of travel.
     - parameters:
     - orientation: A flock of boids to search
     */
    func rotate() {
        zRotation = CGFloat(-atan2(Double(velocity.x), Double(velocity.y))) - orientation.rawValue.degreesToRadians
    }
}
