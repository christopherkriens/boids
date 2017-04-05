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
    let numberOfBoids = 10
    var flock = [Boid]()
    
    override func didMove(to view: SKView) {        
        let randomSource = GKARC4RandomSource()
        let randomHorizontal = GKRandomDistribution(randomSource: randomSource, lowestValue: Int(round(0)), highestValue: Int(round(size.width)))
        let randomVertical = GKRandomDistribution(randomSource: randomSource, lowestValue: Int(round(0)), highestValue: Int(round(size.height)))
        
        for i in 0..<self.numberOfBoids {
            let boid = Boid(texture: SKTexture(imageNamed:"nyan"), color: UIColor.white, size: CGSize(width: 100, height: 75))
            let randomX = randomHorizontal.nextInt()
            let randomY = randomVertical.nextInt()
            
            boid.position = CGPoint(x: randomX, y: randomY)
            boid.name = "boid_\(i)"
            
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
        self.flock = [Boid]()
        removeAllChildren()
        self.didMove(to: self.view!)
    }
}
