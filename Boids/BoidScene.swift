//
//  GameScene.swift
//  Boids
//
//  Created by Christopher Kriens on 4/4/17.


import SpriteKit

class BoidScene: SKScene {
    let numberOfBoids = 80
    private var flock = [Boid]()
    private var shouldIgnoreTouchEnded = false
    private var lastUpdateTime: TimeInterval = 0
    private var frameCount:Int = 0
    private let neighborhoodUpdateFrequency = 30

    override func didMove(to view: SKView) {
        self.backgroundColor = SKColor.black
        
        for i in 0..<self.numberOfBoids {
            // Create a new boid object with Character, e.g. : 🐠 🐟 🐡 🦄 🐔 🚜
            let boid = Boid(withCharacter: "🐠", fontSize: 32)

            // 📱 Position the boid at a random scene location to start
            let randomStartPositionX = round(CGFloat.random(between: 0, and: size.width))
            let randomStartPositionY = round(CGFloat.random(between: 0, and: size.height))
            boid.position = CGPoint(x: randomStartPositionX, y: randomStartPositionY)
            
            // 🎲 Assign slightly randomized speeds for variety in flock movement
            let randomFlockSpeed = CGFloat.random(between: 2, and: 3)
            let randomGoalSpeed = CGFloat.random(between: 5, and: 6)
            boid.maximumFlockSpeed = randomFlockSpeed
            boid.maximumGoalSpeed = randomGoalSpeed
            
            boid.name = "boid-\(i)"
            
            self.flock.append(boid)
            addChild(boid)
        }
    }

    override func update(_ currentTime: TimeInterval) {
        var deltaTime: TimeInterval = self.lastUpdateTime == 0 ? 0 : currentTime - self.lastUpdateTime
        self.lastUpdateTime = currentTime

        frameCount += 1

        // 🏘 The boid will reassess its neighborhood every so often, not every frame
        let shouldUpdateNeighborhood: Bool = frameCount >= self.neighborhoodUpdateFrequency
        if shouldUpdateNeighborhood {
            defer {
                frameCount = 0
            }
        }

        for boid in flock {
            if shouldUpdateNeighborhood {
                boid.assessNeighborhood(forFlock: self.flock)
            }
            boid.updateBoid(inFlock: self.flock, deltaTime: deltaTime)
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
                boid.seek(touchPosition)
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for thisTouch in touches {
            let touchPosition = thisTouch.location(in: self)
            for boid in flock {
                boid.evade(touchPosition)
            }
        }
        // 👈🏼 Ignore false positives for a tap gesture on release
        shouldIgnoreTouchEnded = true
    }
}
