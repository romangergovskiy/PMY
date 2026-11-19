import CoreGraphics
import Foundation
import Observation

@Observable
final class GameSession {

    enum Phase {
        case menu
        case playing
        case results
    }

    enum TapResult {
        case miss
        case hit
        case bonus
    }

    private struct Configuration {
        let speedMultiplier: CGFloat
        let maximumBugCount: Int
        let bonusInterval: TimeInterval
        let roundDuration: TimeInterval
        let goldPoints: Int
    }

    var phase: Phase = .menu
    var bugs: [Bug] = []
    var tiltBonus: TiltBonus?
    var score = 0
    var hits = 0
    var misses = 0
    var timeRemaining: TimeInterval = 0
    var tiltRemaining: TimeInterval = 0

    var tiltUnlocked: Bool { tiltRemaining > 0 }

    private var configuration = Configuration(
        speedMultiplier: 1,
        maximumBugCount: 8,
        bonusInterval: 5,
        roundDuration: 30,
        goldPoints: 100
    )
    private var lastUpdate = Date()
    private var endDate = Date()
    private var spawnElapsed: TimeInterval = 0
    private var rareSpawnElapsed: TimeInterval = 0
    private var tiltBonusElapsed: TimeInterval = 0
    private var goldSpawnElapsed: TimeInterval = 0

    var accuracy: Int {
        let attempts = hits + misses
        guard attempts > 0 else { return 0 }
        return Int((Double(hits) / Double(attempts) * 100).rounded())
    }

    // MARK: - Round

    func start(with settings: GameSettings, goldPoints: Int) {
        configuration = Configuration(
            speedMultiplier: CGFloat(0.55 + settings.speed * 0.11),
            maximumBugCount: Int(settings.maxCockroaches),
            bonusInterval: settings.bonusInterval,
            roundDuration: settings.roundDuration,
            goldPoints: goldPoints
        )
        score = 0
        hits = 0
        misses = 0
        timeRemaining = settings.roundDuration
        spawnElapsed = 0
        rareSpawnElapsed = 0
        tiltBonusElapsed = 0
        goldSpawnElapsed = 0
        tiltRemaining = 0
        tiltBonus = nil
        lastUpdate = Date()
        endDate = lastUpdate.addingTimeInterval(configuration.roundDuration)
        bugs = [
            makeBug(type: .common),
            makeBug(type: .fast),
            makeBug(type: .rare)
        ]
        phase = .playing
    }

    func finish() {
        timeRemaining = 0
        bugs.removeAll()
        tiltBonus = nil
        tiltRemaining = 0
        phase = .results
    }

    func showMenu() {
        bugs.removeAll()
        tiltBonus = nil
        tiltRemaining = 0
        phase = .menu
    }

    // MARK: - Update

    func update(at date: Date, gravity: CGVector = .zero) {
        guard phase == .playing else { return }

        let elapsed = min(max(date.timeIntervalSince(lastUpdate), 0), 0.1)
        lastUpdate = date
        timeRemaining = max(0, endDate.timeIntervalSince(date))

        guard timeRemaining > 0 else {
            finish()
            return
        }

        moveBugs(elapsed: elapsed, gravity: gravity)
        spawnElapsed += elapsed
        rareSpawnElapsed += elapsed
        goldSpawnElapsed += elapsed

        if tiltRemaining > 0 {
            tiltRemaining = max(0, tiltRemaining - elapsed)
            if tiltRemaining == 0 {
                tiltBonusElapsed = 0
            }
        } else {
            tiltBonusElapsed += elapsed
        }

        let regularInterval = max(0.35, 1.25 - Double(configuration.speedMultiplier) * 0.35)
        if spawnElapsed >= regularInterval, bugs.count < configuration.maximumBugCount {
            spawnElapsed = 0
            spawnRegularBug()
        }

        if rareSpawnElapsed >= configuration.bonusInterval,
           bugs.count < configuration.maximumBugCount {
            rareSpawnElapsed = 0
            bugs.append(makeBug(type: .rare))
        }

        if tiltBonus == nil, tiltRemaining == 0, tiltBonusElapsed >= 15 {
            tiltBonusElapsed = 0
            tiltBonus = TiltBonus(position: randomPosition(size: 0.16))
        }

        if goldSpawnElapsed >= 20 {
            goldSpawnElapsed = 0
            bugs.append(makeBug(type: .golden, awardedPoints: configuration.goldPoints))
        }
    }

    func handleTap(at point: CGPoint) -> TapResult {
        guard phase == .playing else { return .miss }

        if let bonus = tiltBonus {
            let radius = bonus.size * 0.62
            let dx = point.x - bonus.position.x
            let dy = point.y - bonus.position.y
            if dx * dx + dy * dy <= radius * radius {
                tiltBonus = nil
                tiltRemaining = 5
                score += 15
                return .bonus
            }
        }

        let hitIndex = bugs.indices.reversed().first { index in
            let bug = bugs[index]
            let radius = bug.size * 0.62
            let dx = point.x - bug.position.x
            let dy = point.y - bug.position.y
            return dx * dx + dy * dy <= radius * radius
        }

        if let hitIndex {
            let bug = bugs.remove(at: hitIndex)
            hits += 1
            score += bug.points
            return .hit
        }

        misses += 1
        score -= 3
        return .miss
    }

    // MARK: - Movement

    private func moveBugs(elapsed: TimeInterval, gravity: CGVector) {
        let gravityStrength: CGFloat = tiltUnlocked ? 2.4 : 0

        for index in bugs.indices {
            var bug = bugs[index]
            let distance = bug.speed * configuration.speedMultiplier * CGFloat(elapsed)
            var x = bug.position.x + bug.velocity.dx * distance + gravity.dx * gravityStrength * CGFloat(elapsed)
            var y = bug.position.y + bug.velocity.dy * distance + gravity.dy * gravityStrength * CGFloat(elapsed)
            let margin = bug.size / 2

            if gravityStrength > 0 {
                bug.velocity.dx += gravity.dx * 1.6 * CGFloat(elapsed)
                bug.velocity.dy += gravity.dy * 1.6 * CGFloat(elapsed)
                let length = hypot(bug.velocity.dx, bug.velocity.dy)
                if length > 1.8 {
                    bug.velocity.dx /= length / 1.8
                    bug.velocity.dy /= length / 1.8
                }
            }

            if x < margin || x > 1 - margin {
                bug.velocity.dx *= -1
                x = min(max(x, margin), 1 - margin)
            }
            if y < margin || y > 1 - margin {
                bug.velocity.dy *= -1
                y = min(max(y, margin), 1 - margin)
            }

            bug.position = CGPoint(x: x, y: y)
            bugs[index] = bug
        }
    }

    // MARK: - Spawning

    private func spawnRegularBug() {
        let type: BugType = Double.random(in: 0...1) < 0.68 ? .common : .fast
        bugs.append(makeBug(type: type))
    }

    private func makeBug(type: BugType, awardedPoints: Int? = nil) -> Bug {
        let angle = CGFloat.random(in: 0...(2 * .pi))
        return Bug(
            position: randomPosition(size: type.size),
            velocity: CGVector(dx: cos(angle), dy: sin(angle)),
            type: type,
            awardedPoints: awardedPoints
        )
    }

    private func randomPosition(size: CGFloat) -> CGPoint {
        let margin = size / 2
        return CGPoint(
            x: CGFloat.random(in: margin...(1 - margin)),
            y: CGFloat.random(in: margin...(1 - margin))
        )
    }
}
