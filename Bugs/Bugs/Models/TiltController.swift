import CoreGraphics
import CoreMotion
import Foundation
import Observation
import UIKit

@Observable
final class TiltController {
    private let manager = CMMotionManager()

    var gravity = CGVector.zero
    var isActive = false

    func start() {
        isActive = true
        guard manager.isDeviceMotionAvailable else { return }
        manager.deviceMotionUpdateInterval = 1.0 / 30.0
        manager.startDeviceMotionUpdates(using: .xArbitraryZVertical, to: .main) { [weak self] motion, _ in
            guard let gravity = motion?.gravity else { return }
            self?.gravity = Self.screenGravity(from: gravity)
        }
    }

    func stop() {
        manager.stopDeviceMotionUpdates()
        gravity = .zero
        isActive = false
    }

    private static func screenGravity(from gravity: CMAcceleration) -> CGVector {
        switch UIDevice.current.orientation {
        case .landscapeLeft:
            return CGVector(dx: CGFloat(gravity.y), dy: CGFloat(gravity.x))
        case .landscapeRight:
            return CGVector(dx: CGFloat(-gravity.y), dy: CGFloat(-gravity.x))
        case .portraitUpsideDown:
            return CGVector(dx: CGFloat(-gravity.x), dy: CGFloat(gravity.y))
        default:
            return CGVector(dx: CGFloat(gravity.x), dy: CGFloat(-gravity.y))
        }
    }
}
