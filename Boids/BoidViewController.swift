//
//  GameViewController.swift
//  Boids
//
//  Created by Christopher Kriens on 4/4/17.

import UIKit
import SpriteKit

class BoidViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        if let view = view as? SKView {
            // Create a BoidScene
            let scene = BoidScene(size: view.bounds.size)
            scene.scaleMode = .aspectFit

            // Present the Scene
            view.presentScene(scene)

            // Configure a few options
            view.ignoresSiblingOrder = true
            //view.showsFPS = true
            view.showsNodeCount = false
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
