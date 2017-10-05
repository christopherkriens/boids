//
//  GameScene.swift
//  Boids
//
//  Created by Christopher Kriens on 4/4/17.


import SpriteKit

class BoidScene: SKScene {
    let numberOfBoids = 75
    private var flock = [Boid]()
    private var lastUpdateTime: TimeInterval = 0
    private var frameCount: Int = 0
    private let neighborhoodUpdateFrequency = 31
    private let perceptionUpdateFrequency = 37
    private var touchDownOccurred = false
    private var feedbackGenerator: UIImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)

    override func didMove(to view: SKView) {
        backgroundColor = SKColor.black
        
        for i in 0..<numberOfBoids {
            // Create a new boid object with Character, e.g. : 🐠 🐟 🐡 🦄 🐔 🚜
            let boid = Boid(withCharacter: "🐠", fontSize: 30)

            // Position the boid at a random scene location to start
            let randomStartPositionX = round(CGFloat.random(between: 0, and: size.width))
            let randomStartPositionY = round(CGFloat.random(between: 0, and: size.height))
            boid.position = CGPoint(x: randomStartPositionX, y: randomStartPositionY)
            
            // Assign slightly randomized speeds for variety in flock movement
            let randomFlockSpeed = CGFloat.random(between: 2, and: 3)
            let randomGoalSpeed = CGFloat.random(between: 5, and: 6)
            boid.maximumFlockSpeed = randomFlockSpeed
            boid.maximumGoalSpeed = randomGoalSpeed
            
            boid.name = "boid-\(i)"
            
            flock.append(boid)
            addChild(boid)
        }
    }

    override func update(_ currentTime: TimeInterval) {
        let deltaTime: TimeInterval = lastUpdateTime == 0 ? 0 : currentTime - lastUpdateTime
        lastUpdateTime = currentTime

        frameCount += 1

        for boid in flock {
            // The boid should reevaluate its neighborhood every so often
            if frameCount % neighborhoodUpdateFrequency == 0 {
                boid.evaluateNeighborhood(forFlock: flock)
            }
            
            // The boid should recalculate its perception every so often
            if frameCount % perceptionUpdateFrequency == 0 {
                boid.updatePerception()
            }
            
            boid.updateBoid(inFlock: flock, deltaTime: deltaTime)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchDownOccurred = false
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        // If Force Touch isn't available, just use Seek
        guard view?.traitCollection.forceTouchCapability == .available else {
            if let touchPosition = touches.first?.location(in: self) {
                for boid in flock {
                    boid.seek(touchPosition)
                }
            }
            return
        }
        
        if let touch = touches.first {
            let touchLocation = touch.location(in: self)
            let normalTouchRange: ClosedRange<CGFloat> = 0.0...0.7
            let forceTouchRange: ClosedRange<CGFloat> = 0.7...CGFloat.greatestFiniteMagnitude
            
            // Prepare the Taptic Engine to reduce latency
            feedbackGenerator.prepare()
            
            // Use light touches as Seek and heavy touches as Evade
            switch touch.force {
            case normalTouchRange:
                guard !touchDownOccurred else { return }
                for boid in flock {
                    boid.seek(touchLocation)
                }
            case forceTouchRange:
                for boid in flock {
                    boid.evade(touchLocation)
                }

                // Provide haptic feedback when switching to Evade
                if !touchDownOccurred {
                    feedbackGenerator.impactOccurred()
                }
                touchDownOccurred = true
            default:
                break
            }
        }
    }
}
