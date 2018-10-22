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
    private var frameCount: Int = 0
    private let neighborhoodUpdateFrequency = 31
    private let perceptionUpdateFrequency = 37
    private var lightTouchOccurred = false
    private var forceTouchOccurred = false
    private var lightFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    private var heavyFeedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)

    override func didMove(to view: SKView) {
        backgroundColor = SKColor.black

        for i in 0..<numberOfBoids {
            // Create a new boid object with Character, e.g. : 🐠 🐟 🐡 🦄 🐔 🚜
            let boid = Boid(withCharacter: "🐠", fontSize: 26)

            // Position the boid at a random scene location to start

            let randomStartPositionX = round(CGFloat.random(in: 1...size.width))
            let randomStartPositionY = round(CGFloat.random(in: 1...size.height))
            boid.position = CGPoint(x: randomStartPositionX, y: randomStartPositionY)

            // Varying fear thresholds prevents "boid walls" during evade

            boid.fearThreshold = CGFloat.random(in: boid.radius*6...boid.radius*8)

            // Assign slightly randomized speeds for variety in flock movement

            let randomFlockSpeed = CGFloat.random(in: 2...3)
            let randomGoalSpeed = CGFloat.random(in: 5...6)
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

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Prepare the Taptic Engine to reduce latency
        lightFeedbackGenerator.prepare()
        heavyFeedbackGenerator.prepare()

        touchesMoved(touches, with: event)

        lightFeedbackGenerator.impactOccurred()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        lightTouchOccurred = false
        forceTouchOccurred = false
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
            let forceTouchRange: PartialRangeFrom<CGFloat> = normalTouchRange.upperBound...

            // Use light touches as Seek and heavy touches as Evade
            switch touch.force {
            case normalTouchRange:
                //guard !forceTouchOccurred else { return }
                for boid in flock {
                    boid.seek(touchLocation)
                }
                if !lightTouchOccurred {
                    lightFeedbackGenerator.impactOccurred()
                }
                lightTouchOccurred = true
                forceTouchOccurred = false

            case forceTouchRange:
                for boid in flock {
                    boid.evade(touchLocation)
                }

                // Provide haptic feedback when switching to Evade
                if !forceTouchOccurred {
                    heavyFeedbackGenerator.impactOccurred()
                }
                forceTouchOccurred = true
                lightTouchOccurred = false

            default:
                break
            }
        }
    }
}
