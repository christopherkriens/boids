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
    
    var rules = [Rule]()
    
    var hasGoal = false
    var goalPosition = CGPoint.zero
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)

        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.position = CGPoint.zero
        self.zPosition = 2
        self.name = "boid"
        self.currentSpeed = maximumFlockSpeed
 
        self.rules = [CenterOfMass(), Separation(), Alignment()]
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
        for var rule in self.rules {
            rule.apply(toBoid: self, inFlock: flock)
        }
        self.updatePosition(frame: frame)
    }
    
    private func updatePosition(frame: CGRect) {
        //*** Sum the vectors from each of the rules ***//
        self.velocity += self.rules.reduce(self.velocity, { velocity, rule in
            return velocity + rule.velocity
        })
        
        //*** Move toward any goals ***//
        moveToGoal()
        
        //*** Make sure the result vector won't move the boid faster than the max speed ***//
        applySpeedLimit()

        //*** Keep the flock within the frame bounds ***//
        constrainToFrame(frame: frame)
        
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
    
    private func constrainToFrame(frame: CGRect) {
        let borderMargin = 100
        let xMin: CGFloat = CGFloat(borderMargin)
        let xMax: CGFloat = frame.size.width - CGFloat(borderMargin)
        let yMin: CGFloat = CGFloat(borderMargin)
        let yMax: CGFloat = frame.size.height - CGFloat(borderMargin)
        let borderTurnResistance: CGFloat = self.currentSpeed * (1/5)
        
        if (self.position.x < xMin) {
            self.velocity.x += borderTurnResistance
        }
        if (self.position.x > xMax) {
            self.velocity.x -= borderTurnResistance
        }
        
        if (self.position.y < yMin) {
            self.velocity.y += borderTurnResistance
        }
        if (self.position.y > yMax) {
            self.velocity.y -= borderTurnResistance
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

        // flip graphic bitch if traveling left or right
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
