//
//  GameViewController.swift
//  Boids
//
//  Created by Christopher Kriens on 4/4/17.
//
//
// Algorithm: http://www.kfish.org/boids/pseudocode.html

import UIKit
import SpriteKit
import GameplayKit

class BoidViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            let scene = BoidScene(size: self.view.bounds.size)
            scene.scaleMode = .aspectFit
                
            // Present the scene
            view.presentScene(scene)

            // Configure
            view.ignoresSiblingOrder = true
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }

    
    override var shouldAutorotate: Bool {
        return true
    }

    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
