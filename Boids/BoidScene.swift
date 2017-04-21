//
//  GameScene.swift
//  Boids
//
//  Created by Christopher Kriens on 4/4/17.


import SpriteKit

class BoidScene: SKScene {
    let numberOfBoids = 50
    private var flock = [Boid]()
    private var lastUpdateTime: TimeInterval = 0
    private var frameCount:Int = 0
    private let neighborhoodUpdateFrequency = 10

    override func didMove(to view: SKView) {
        self.backgroundColor = SKColor.black
        
        for i in 0..<self.numberOfBoids {
            // Create a new boid object with Character, e.g. : 🐠 🐟 🐡 🦄 🐔 🚜
            let boid = Boid(withCharacter: "🐠", fontSize: 34)

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
        let deltaTime: TimeInterval = self.lastUpdateTime == 0 ? 0 : currentTime - self.lastUpdateTime
        self.lastUpdateTime = currentTime

        frameCount += 1

        // 🏘 The boid will reassess its neighborhood every so often, not every frame
        let shouldUpdateNeighborhood: Bool = frameCount >= self.neighborhoodUpdateFrequency

        for boid in flock {
            if shouldUpdateNeighborhood {
                boid.assessNeighborhood(forFlock: self.flock)
            }
            boid.updateBoid(inFlock: self.flock, deltaTime: deltaTime)
        }
        if shouldUpdateNeighborhood {
            frameCount = 0
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard self.view?.traitCollection.forceTouchCapability == .available else {
            if let touchPosition = touches.first?.location(in: self) {
                for boid in flock {
                    boid.seek(touchPosition)
                }
            }
            return
        }
    
        if let touchPosition = touches.first?.location(in: self) {
            let normalTouchRange: ClosedRange<CGFloat> = 0.0...0.5
            let forceTouchRange: ClosedRange<CGFloat> = 0.5...CGFloat.greatestFiniteMagnitude
            let touch = touches.first!

            switch touch.force {
            case normalTouchRange:
                for boid in flock {
                    boid.seek(touchPosition)
                }
            case forceTouchRange:
                if let touchPosition = touches.first?.location(in: self) {
                    for boid in flock {
                        boid.evade(touchPosition)
                    }
                }
            default:
                break
            }
            
            
            
            
        }
    }
}
