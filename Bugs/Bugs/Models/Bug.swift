import CoreGraphics
import Foundation

enum BugType: String, CaseIterable {
    case common
    case fast
    case rare

    var title: String {
        switch self {
        case .common:
            return "Обычный"
        case .fast:
            return "Быстрый"
        case .rare:
            return "Редкий"
        }
    }

    var speed: CGFloat {
        switch self {
        case .common:
            return 0.13
        case .fast:
            return 0.25
        case .rare:
            return 0.18
        }
    }

    var size: CGFloat {
        switch self {
        case .common:
            return 0.15
        case .fast:
            return 0.11
        case .rare:
            return 0.18
        }
    }

    var points: Int {
        switch self {
        case .common:
            return 5
        case .fast:
            return 10
        case .rare:
            return 25
        }
    }

    var assetName: String {
        switch self {
        case .common:
            return "bug-common"
        case .fast:
            return "bug-fast"
        case .rare:
            return "bug-rare"
        }
    }
}

struct Bug: Identifiable, Equatable {
    let id: UUID
    var position: CGPoint
    var velocity: CGVector
    let type: BugType

    var speed: CGFloat { type.speed }
    var size: CGFloat { type.size }
    var points: Int { type.points }
    var assetName: String { type.assetName }

    init(
        id: UUID = UUID(),
        position: CGPoint,
        velocity: CGVector,
        type: BugType
    ) {
        self.id = id
        self.position = position
        self.velocity = velocity
        self.type = type
    }
}
