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
    
    private var timer: Timer?
    private var perceivedCenter = CGPoint.zero
    private var perceivedDirection = CGPoint.zero
    
    var radius: CGFloat {
        return min(self.size.width, self.size.height)
    }

    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        self.currentSpeed = maximumFlockSpeed

        super.init(texture: texture, color: color, size: size)

        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.position = CGPoint.zero
        self.zPosition = 2
        self.name = "boid"

        self.behaviors = [Cohesion(intensity: 0.005), Separation(intensity: 0.03), Alignment(intensity: 0.2), Bound()]
        self.goals = []
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func seek(to point:CGPoint) {
        self.destination = point
        self.goals.append(Seek())
    }
    
    func evade(from point:CGPoint) {
        self.destination = point
        self.goals.append(Evade())
    }
    
    /*func removeGoals() {
        self.goals.removeAll()
    }*/

    func updateBoid(withinFlock flock: [Boid], frame: CGRect) {

        // Optimization: The original algorithm calls for each boid calculating
        // its own center of mass, which involves iterating over the group for 
        // each boid.  Let's instead calculate it once and send the value as a 
        // parameter to the Cohesion Behavior.
        self.perceivedCenter = (flock.reduce(CGPoint.zero) { $0 + $1.position }) / CGFloat(flock.count)
        self.perceivedCenter -= self.position / CGFloat(flock.count)
        
        // Possible enhancement; Apply a distance limit to a boid's ability to
        // calculate its center of mass and direction.  Could lead to groups 
        // separating off and merging back together

        // Optimization: The original algorithm calls for each boid calculating
        // its own average group velocity, which involves iterating over the group
        // for each boid.  Let's instead calculate it once and send the value as a
        // parameter to the Alignment Behavior.
        self.perceivedDirection = (flock.reduce(CGPoint.zero) { $0 + $1.velocity }) / CGFloat(flock.count)
        self.perceivedDirection -= (self.velocity / CGFloat(flock.count))

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
        //** Remove any goals that have been achieved **//
        self.goals = self.goals.filter { $0.achieved == false }

        self.updatePosition(frame: frame)
    }

    private func updatePosition(frame: CGRect) {
        let momentum: CGFloat = 5
        
        //** Goals take priority over flocking behaviors **//
        if self.goals.count > 0 {
            //*** Move toward the average destination of all goals ***//
            self.velocity += (self.goals.reduce(self.velocity) { $0 + $1.point }) / momentum
        } else {
            //*** Move the average velocity from each of the behaviors ***//
            self.velocity += (self.behaviors.reduce(self.velocity) { $0 + $1.velocity }) / momentum
        }

        applySpeedLimit()

        //*** Rotate in the direction of travel ***//
        rotate()
        
        self.position += self.velocity
    }
    
    private func applySpeedLimit() {

        // Enhancement: If the boid has become separated from the group,
        // allow a temporary increase in velocity until it's able to rejoin
        /*if self.perceivedCenter.distance(from: self.position) > 200 {
            self.velocity = self.perceivedCenter
            self.currentSpeed = maximumGoalSpeed * 2
        }*/
        
        if self.goals.count > 0 {
            currentSpeed = maximumGoalSpeed
        } else {
            currentSpeed = maximumFlockSpeed
        }
        
        let vector = self.velocity.length
        if (vector > self.currentSpeed) {
            let unitVector = self.velocity / vector
            self.velocity = unitVector * self.currentSpeed
        }
    }

    private func rotate() {
        let currentIdealDirection = CGFloat(-atan2(Double(velocity.x), Double(velocity.y)))
        self.zRotation = currentIdealDirection + CGFloat(GLKMathDegreesToRadians(90))

        if self.velocity.x < 0 {
            /*let flip = SKAction.scaleX(to: -1, duration: 0.1)
            self.setScale(1.0)
            self.run(flip)
            self.zRotation += CGFloat(GLKMathDegreesToRadians(180))*/
        } else {
            /*let flip = SKAction.scaleX(to: 1, duration: 0.1)
            self.setScale(1.0)
            self.run(flip)*/
        }
    }
}
