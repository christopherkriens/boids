import UIKit
import GameplayKit


/**
 Goal protocol
 - All goals must adopt this protocol
 **/
protocol Goal {
    var destination: CGPoint { get }
}

/**
 Travel
 
 - This moves the boid toward a point
 **/
class Travel: Goal {
    var destination: CGPoint = CGPoint.zero
    let goalThreshhold: CGFloat = 5

    func move(boid:Boid, toPoint destination:CGPoint) {
        guard boid.position.distance(from: destination) > goalThreshhold else {
            boid.currentSpeed *= 1.5
            return
        }
        boid.velocity = (destination - boid.position)
    }
}
