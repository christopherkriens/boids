import UIKit
import GameplayKit


/**
 Goal protocol
 - All goals must adopt this protocol
 **/
protocol Goal {
    var destination: CGPoint { get set }
    var achieved: Bool { get set }
    init(destination: CGPoint)
    init()
}

extension Goal {
    init (destination: CGPoint) {
        self.init()
        self.achieved = false
        self.destination = destination
    }
}

/**
 Travel
 
 - This moves the boid toward a point
 **/
final class Seek: Goal {
    var achieved: Bool = false
    var destination: CGPoint = CGPoint.zero

    func move(boid:Boid, toPoint destination:CGPoint) {
        let goalThreshhold: CGFloat = boid.radius

        guard boid.position.distance(from: destination) > goalThreshhold else {
            self.achieved = true
            boid.currentSpeed = boid.maximumFlockSpeed
            return
        }
        boid.currentSpeed = boid.maximumGoalSpeed
        boid.velocity = (destination - boid.position)
    }
}
