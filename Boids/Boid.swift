//
//  Boid.swift
//  Boids
//
//  Created by Christopher Kriens on 4/5/17.
//
//

import SpriteKit
import GameplayKit

class Boid: SKSpriteNode {
    let maximumFlockSpeed: CGFloat = 2
    let maximumGoalSpeed: CGFloat = 6
    var currentSpeed: CGFloat = 2
    let radius: CGFloat = 30.0
    var velocity = CGPoint.zero
    var rotationalVelocity: CGFloat = 0.0
    
    var behaviors = [Behavior]()
    var hasGoal = false
    var goalPosition = CGPoint.zero
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)

        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.position = CGPoint.zero
        self.zPosition = 2
        self.name = "boid"
        self.currentSpeed = maximumFlockSpeed
 
        self.behaviors = [Cohesion(), Separation(), Alignment(), Bound()]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setGoal(toGoal goal:CGPoint) {
        self.hasGoal = true
        self.goalPosition = goal
        self.currentSpeed = maximumGoalSpeed
    }
    
    func updateBoid(withinFlock flock: [Boid], frame: CGRect) {

        // Optimization: The original algorithm calls for each boid calculating
        // its own center of mass, which involves iterating over the group for 
        // each boid.  Let's instead calculate it once and send the value as a 
        // parameter to the Cohesion Behavior.
        let centerOfFlock = (flock.reduce(CGPoint.zero) { $0 + $1.position }) / CGFloat(flock.count)
        
        // Optimization: The original algorithm calls for each boid calculating
        // its own average group velocity, which involves iterating over the group
        // for each boid.  Let's instead calculate it once and send the value as a
        // parameter to the Alignment Behavior.
        let flockDirection = (flock.reduce(CGPoint.zero) { $0 + $1.velocity }) / CGFloat(flock.count)
        
        for behavior in self.behaviors {
            let behaviorClass = String(describing: type(of: behavior))
    
            switch behaviorClass {
            case String(describing: Cohesion.self):
                let cohension = behavior as? Cohesion
                cohension?.apply(toBoid: self, inFlock: flock, withCenterOfMass:centerOfFlock)
            case String(describing: Separation.self):
                let separation = behavior as? Separation
                separation?.apply(toBoid: self, inFlock: flock)
            case String(describing: Alignment.self):
                let alignment = behavior as? Alignment
                alignment?.apply(toBoid: self, inFlock: flock, withAlignment: flockDirection)
            case String(describing: Bound.self):
                let bound = behavior as? Bound
                bound?.apply(toBoid: self, inFrame: frame)
            default: break
            }
        }

        self.updatePosition(frame: frame)
    }
    
    private func updatePosition(frame: CGRect) {
        //*** Sum the vectors from each of the behaviors ***//
        self.velocity += self.behaviors.reduce(self.velocity) { $0 + $1.velocity }
        
        //*** Move toward any goals ***//
        moveToGoal()
        
        //*** Make sure the result vector won't move the boid faster than the max speed ***//
        applySpeedLimit()
        
        //*** Rotate in the direction of travel ***//
        rotate()
        
        self.position += self.velocity
        
        let goalThreshhold: CGFloat = 5
        if (self.position.distance(from: goalPosition) < goalThreshhold) {
            self.hasGoal = false
            self.currentSpeed = maximumFlockSpeed
            self.goalPosition = CGPoint.zero
        }
    }
    
    private func applySpeedLimit() {
        let vector = self.velocity.length
        if (vector > self.currentSpeed) {
            let unitVector = self.velocity / vector
            self.velocity = unitVector * self.currentSpeed
        }
    }

    private func moveToGoal() {
        guard self.hasGoal else { return }
        self.velocity = (self.goalPosition - self.position)
    }
    
    private func rotate() {
        let currentIdealDirection = CGFloat(-atan2(Double(velocity.x), Double(velocity.y)))
        if (self.rotationalVelocity == 0.0) {
           self.rotationalVelocity = currentIdealDirection
        }
        self.rotationalVelocity = (currentIdealDirection/100 + self.rotationalVelocity)
        self.zRotation = currentIdealDirection + CGFloat(GLKMathDegreesToRadians(90))

        if self.velocity.x < 0 {
            let flip = SKAction.scaleX(to: -1, duration: 0.1)
            self.setScale(1.0)
            self.run(flip)
            self.zRotation += CGFloat(GLKMathDegreesToRadians(180))
        } else {
            let flip = SKAction.scaleX(to: 1, duration: 0.1)
            self.setScale(1.0)
            self.run(flip)
        }
    }
}
