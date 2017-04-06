//
//  Boid.swift
//  Boids
//
//  Created by Christopher Kriens on 4/5/17.
//
//

import SpriteKit

class Boid: SKSpriteNode {
    let maximumSpeed: CGFloat = 2
    let radius: CGFloat = 10.0
    var velocity = CGPoint.zero
    var rotationalVelocity: CGFloat = 0.0
    var rules = [Rule]()
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.position = CGPoint.zero
        self.zPosition = 2
        self.name = "boid"
            
        self.rules = [CenterOfMass(), Separation(), Alignment()]
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func updateBoid(withinFlock flock: [Boid], frame: CGRect) {
        for var rule in self.rules {
            rule.apply(toBoid: self, inFlock: flock)
        }
        self.updatePosition(frame: frame)
    }
    
    
    private func updatePosition(frame: CGRect) {
        
        self.velocity += self.rules.reduce(self.velocity, { velocity, rule in
            return velocity + rule.velocity
        })

        applySpeedLimit()

        let borderMargin = 100
        let xMin: CGFloat = CGFloat(borderMargin)
        let xMax: CGFloat = frame.size.width - CGFloat(borderMargin)
        let yMin: CGFloat = CGFloat(borderMargin)
        let yMax: CGFloat = frame.size.height - CGFloat(borderMargin)

        let borderTurnResistance: CGFloat = maximumSpeed * (1/10)
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

        self.position += self.velocity
        rotate()
    }
    
    private func applySpeedLimit() {
        let vector = self.velocity.length
        if (vector > self.maximumSpeed) {
            let unitVector = self.velocity / vector
            self.velocity = unitVector * self.maximumSpeed
        }
    }
    
    private func rotate() {
        let currentIdealDirection = CGFloat(-atan2(Double(velocity.x), Double(velocity.y)))
        if (self.rotationalVelocity == 0.0) {
           self.rotationalVelocity = currentIdealDirection
        }
        self.rotationalVelocity = ((currentIdealDirection/100 + self.rotationalVelocity) / 2)
        self.zRotation = currentIdealDirection + CGFloat(GLKMathDegreesToRadians(90))
    }
}
