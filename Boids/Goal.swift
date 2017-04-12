import UIKit
import GameplayKit


/**
 Goal protocol
 - All goals must adopt this protocol
 **/
protocol Goal {
    var point: CGPoint { get set }
    var achieved: Bool { get set }
    init(point: CGPoint)
    init()
}

extension Goal {
    init (point: CGPoint) {
        self.init()
        self.achieved = false
        self.point = point
    }
}

/**
 Travel
 
 - This moves the boid toward a point
 **/
final class Seek: Goal {
    var achieved: Bool = false
    var point: CGPoint = CGPoint.zero
    
    func move(boid:Boid, toPoint destination:CGPoint) {
        let goalThreshhold: CGFloat = boid.radius
        
        guard boid.position.distance(from: destination) > goalThreshhold else {
            self.achieved = true
            boid.currentSpeed = boid.maximumFlockSpeed
            return
        }
       // boid.currentSpeed = boid.maximumGoalSpeed
        boid.velocity = (destination - boid.position)
    }
}

final class Evade: Goal {
    var achieved: Bool = false
    var point: CGPoint = CGPoint.zero
    
    func move(boid:Boid, fromPoint destination:CGPoint) {
        let fearThreshold: CGFloat = boid.radius * 4

        if boid.position.distance(from: destination) < fearThreshold {
           // boid.currentSpeed = boid.maximumGoalSpeed
            boid.velocity = -(destination - boid.position)
        } else {
            //boid.currentSpeed = boid.maximumFlockSpeed
            boid.goals.removeAll() // only works if there's one, but testable!
        }
    }
}
