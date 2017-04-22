//
//  GameScene.swift
//  Boids
//
//  Created by Christopher Kriens on 4/4/17.


import SpriteKit

class BoidScene: SKScene {
    let numberOfBoids = 100
    private var flock = [Boid]()
    private var lastUpdateTime: TimeInterval = 0
    private var frameCount:Int = 0
    private let neighborhoodUpdateFrequency = 37
    private let perceptionUpdateFrequency = 31
    private var shouldIgnoreReturnTouch = false

    override func didMove(to view: SKView) {
        self.backgroundColor = SKColor.black
        
        for i in 0..<self.numberOfBoids {
            // Create a new boid object with Character, e.g. : 🐠 🐟 🐡 🦄 🐔 🚜
            let boid = Boid(withCharacter: "🐠", fontSize: 30)

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

        for boid in flock {
            // 🏡🏠 The boid should reevaluate its neighborhood every so often
            if frameCount % neighborhoodUpdateFrequency == 0 {
                boid.evaluateNeighborhood(forFlock: self.flock)
            }
            
            // 👁👁 The boid should recalculate its perception every so often
            if frameCount % perceptionUpdateFrequency == 0 {
                boid.updatePerception()
            }
            
            boid.updateBoid(inFlock: self.flock, deltaTime: deltaTime)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        shouldIgnoreReturnTouch = false
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        // ⚠️ Make sure that Force Touch is available
        guard self.view?.traitCollection.forceTouchCapability == .available else {
            if let touchPosition = touches.first?.location(in: self) {
                for boid in flock {
                    boid.seek(touchPosition)
                }
            }
            return
        }
        
        if let touch = touches.first {
            let touchLocation = touch.location(in: self)
            let normalTouchRange: ClosedRange<CGFloat> = 0.0...0.5
            let forceTouchRange: ClosedRange<CGFloat> = 0.5...CGFloat.greatestFiniteMagnitude
            
            // 👈 Use light touches as seek and heavy touches as evade
            switch touch.force {
            case normalTouchRange:
                guard !shouldIgnoreReturnTouch else { return }
                for boid in flock {
                    boid.seek(touchLocation)
                }
            case forceTouchRange:
                for boid in flock {
                    boid.evade(touchLocation)
                }
                shouldIgnoreReturnTouch = true
            default:
                break
            }

        }
    }
}
