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
    let radius = 10.0
    var velocity = CGPoint.zero
    var rules = [Rule]()
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.position = CGPoint.zero
        self.zPosition = 2
        self.name = "boid"
    
        self.rules = [CenterOfMass(), Separation()]
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
        let vector = self.velocity.length
        if (vector > self.maximumSpeed) {
            self.velocity = (self.velocity / vector) * self.maximumSpeed
        }
        self.position += self.velocity
        
        // collision detection and inverting direction - ugly AF
        if (self.position.x - CGFloat(self.radius) <= 0) {
            self.position.x = CGFloat(self.radius)
            self.velocity.x *= -1
        }
        if (self.position.x + CGFloat(self.radius) >= frame.width) {
            self.position.x = frame.width - CGFloat(self.radius)
            self.velocity.x *= -1
        }
        
        if (self.position.y - CGFloat(self.radius) <= 0) {
            self.position.y = CGFloat(self.radius)
            self.velocity.y *= -1
        }
        if (self.position.y + CGFloat(self.radius) >= frame.height) {
            self.position.y = frame.height - CGFloat(self.radius)
            self.velocity.y *= -1
        }
    
        let radian = -atan2(Double(velocity.x), Double(velocity.y))
        self.zRotation = CGFloat(radian)
    }
}
