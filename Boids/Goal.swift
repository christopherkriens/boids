import UIKit
import GameplayKit


/**
 Goal protocol
 - All goals must adopt this protocol
 **/
protocol Goal {
    var point: CGPoint { get set }
    init(point: CGPoint)
    init()
}

extension Goal {
    init (point: CGPoint) {
        self.init()
        self.point = point
    }
}

/**
 Seek
 
 - This moves the boid toward a point in the frame
 **/
final class Seek: Goal {
    var achieved: Bool = false
    var point: CGPoint = CGPoint.zero
    
    func move(boid:Boid, toPoint destination:CGPoint) {
        let goalThreshhold: CGFloat = boid.radius
        
        guard boid.position.distance(from: destination) > goalThreshhold else {
            boid.currentSpeed = boid.maximumFlockSpeed
            boid.goals = boid.goals.filter() { $0 as? Seek !== self }
            return
        }
        boid.velocity = (destination - boid.position)
    }
}

/**
 Evade
 
 - This moves the boid away from a point in the frame
 **/
final class Evade: Goal {
    var point: CGPoint = CGPoint.zero
    
    func move(boid:Boid, fromPoint destination:CGPoint) {
        let fearThreshold: CGFloat = boid.radius * 4

        if boid.position.distance(from: destination) < fearThreshold {
            boid.velocity = -(destination - boid.position)
        } else {
            boid.goals = boid.goals.filter() { $0 as? Evade !== self }
        }
    }
}
