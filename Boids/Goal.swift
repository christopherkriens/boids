import UIKit
import GameplayKit


/**
 Goal protocol
 - All goals must adopt this protocol
 **/
protocol Goal {
    var destination: CGPoint { get }
    var achieved: Bool { get }
}

/**
 Travel
 
 - This moves the boid toward a point
 **/
class Travel: Goal {
    var achieved: Bool = false
    var destination: CGPoint = CGPoint.zero
    
    let goalThreshhold: CGFloat = 5

    func move(boid:Boid, toPoint destination:CGPoint) {
        guard boid.position.distance(from: destination) > goalThreshhold else {
            self.achieved = true
            boid.currentSpeed = boid.maximumFlockSpeed
            return
        }
        boid.currentSpeed = boid.maximumGoalSpeed
        boid.velocity = (destination - boid.position)
    }
}
