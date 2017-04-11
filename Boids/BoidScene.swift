//
//  GameScene.swift
//  Boids
//
//  Created by Christopher Kriens on 4/4/17.
//
//

import SpriteKit
import GameplayKit

class BoidScene: SKScene {
    let numberOfBoids = 50
    var flock = [Boid]()
    
    override func didMove(to view: SKView) {
        self.backgroundColor = SKColor(colorLiteralRed: (2/255), green: (125/255), blue: (145/255), alpha: 1.0)
    
        let randomSource = GKARC4RandomSource()
        let randomHorizontal = GKRandomDistribution(randomSource: randomSource, lowestValue: Int(round(0)), highestValue: Int(round(size.width)))
        let randomVertical = GKRandomDistribution(randomSource: randomSource, lowestValue: Int(round(0)), highestValue: Int(round(size.height)))
        let randomSpeed = GKRandomDistribution(randomSource: randomSource, lowestValue: Int(round(2)), highestValue: Int(round(3)))
        
        for i in 0..<self.numberOfBoids {
            let boid = Boid(texture: SKTexture(imageNamed:"tang"), color: UIColor.white, size: CGSize(width: 40, height: 32))
            let randomX = randomHorizontal.nextInt()
            let randomY = randomVertical.nextInt()
            
            boid.position = CGPoint(x: randomX, y: randomY)
            boid.name = "boid\(i)"
            //boid.maximumFlockSpeed = CGFloat(randomSpeed.nextInt())
            
            self.flock.append(boid)
            addChild(boid)
        }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        for boid in flock {
            boid.updateBoid(withinFlock: self.flock, frame: self.frame)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchPosition = touch.previousLocation(in: self)
            for boid in flock {
                boid.setGoal(toGoal: touchPosition)
            }
        }
    }
}
