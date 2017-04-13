//
//  GameScene.swift
//  Boids
//
//  Created by Christopher Kriens on 4/4/17.
//
//

import SpriteKit

class BoidScene: SKScene {
    let numberOfBoids = 40
    var flock = [Boid]()
    var moving = false
    
    override func didMove(to view: SKView) {
        self.backgroundColor = SKColor(colorLiteralRed: (2/255), green: (125/255), blue: (145/255), alpha: 1.0)
                
        for i in 0..<self.numberOfBoids {
            let boid = Boid(texture: SKTexture(imageNamed:"tang"), color: .white, size: CGSize(width: 40, height: 32))
            
            let randomStartPositionX = round(CGFloat.random(min: 0, max: size.width))
            let randomStartPositionY = round(CGFloat.random(min: 0, max: size.height))
            let randomFlockSpeed = CGFloat.random(min: 2, max: 3)
            let randomGoalSpeed = CGFloat.random(min: 5, max: 6)
            
            boid.maximumFlockSpeed = randomFlockSpeed
            boid.maximumGoalSpeed = randomGoalSpeed
            
            boid.position = CGPoint(x: randomStartPositionX, y: randomStartPositionY)
            boid.name = "boid-\(i)"
            
            self.flock.append(boid)
            addChild(boid)
        }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        for boid in flock {
            boid.updateBoid(withinFlock: self.flock, frame: self.frame)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if moving {
            moving = false
            return
        }
        
        if let touch = touches.first {
            let touchPosition = touch.location(in: self)
            for boid in flock {
                boid.seek(to: touchPosition)
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchPosition = touch.location(in: self)
            let previousTouchPoistion = touch.previousLocation(in: self)
            
            if touchPosition != previousTouchPoistion {
                moving = true
                for boid in flock {
                    boid.evade(from: touchPosition)
                }
            }
        }
    }
}
