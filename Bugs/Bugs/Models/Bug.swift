import CoreGraphics
import Foundation

enum BugType: String, CaseIterable {
    case common
    case fast
    case rare
    case golden

    var title: String {
        switch self {
        case .common:
            return "Обычный"
        case .fast:
            return "Быстрый"
        case .rare:
            return "Редкий"
        case .golden:
            return "Золотой"
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
        case .golden:
            return 0.16
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
        case .golden:
            return 0.17
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
        case .golden:
            return 100
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
        case .golden:
            return "bug-gold"
        }
    }
}

struct Bug: Identifiable, Equatable {
    let id: UUID
    var position: CGPoint
    var velocity: CGVector
    let type: BugType
    let awardedPoints: Int

    var speed: CGFloat { type.speed }
    var size: CGFloat { type.size }
    var points: Int { awardedPoints }
    var assetName: String { type.assetName }

    init(
        id: UUID = UUID(),
        position: CGPoint,
        velocity: CGVector,
        type: BugType,
        awardedPoints: Int? = nil
    ) {
        self.id = id
        self.position = position
        self.velocity = velocity
        self.type = type
        self.awardedPoints = awardedPoints ?? type.points
    }
}

struct TiltBonus: Identifiable, Equatable {
    let id: UUID
    var position: CGPoint
    let size: CGFloat

    init(
        id: UUID = UUID(),
        position: CGPoint,
        size: CGFloat = 0.16
    ) {
        self.id = id
        self.position = position
        self.size = size
    }
}
