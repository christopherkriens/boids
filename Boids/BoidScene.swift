//
//  GameScene.swift
//  Boids
//
//  Created by Christopher Kriens on 4/4/17.


import SpriteKit

class BoidScene: SKScene {
    let numberOfBoids = 50
    var flock = [Boid]()
    var shouldIgnoreTouchEnded = false
    
    override func didMove(to view: SKView) {
        self.backgroundColor = SKColor.white
        
        for i in 0..<self.numberOfBoids {
            // Create a new boid object
            let boid = Boid()//texture: SKTexture(imageNamed:"tang"), color: .white, size: CGSize(width: 40, height: 32))
            
            let boidlabel = SKLabelNode(text: "🐠") // 🐠 🐟 🐡 🦄 🐔 🚜
            boidlabel.fontSize = 36
            boid.addChild(boidlabel)

            // 🎲 Position the boid at a random screen location to start
            let randomStartPositionX = round(CGFloat.random(min: 0, max: size.width))
            let randomStartPositionY = round(CGFloat.random(min: 0, max: size.height))
            boid.position = CGPoint(x: randomStartPositionX, y: randomStartPositionY)
            
            // 🎲 Assign a randomized speed for flocking and goals for variety in flock movement
            let randomFlockSpeed = CGFloat.random(min: 3, max: 4)
            let randomGoalSpeed = CGFloat.random(min: 6, max: 7)
            boid.maximumFlockSpeed = randomFlockSpeed
            boid.maximumGoalSpeed = randomGoalSpeed
            
            boid.size = CGSize(width: boidlabel.fontSize, height: boidlabel.fontSize)
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
        if shouldIgnoreTouchEnded {
            shouldIgnoreTouchEnded = false
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
        for thisTouch in touches {
            let touchPosition = thisTouch.location(in: self)
            for boid in flock {
                boid.evade(from: touchPosition)
            }
            shouldIgnoreTouchEnded = true
        }
    }
}
