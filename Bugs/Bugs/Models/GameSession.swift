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

    private struct Configuration {
        let speedMultiplier: CGFloat
        let maximumBugCount: Int
        let bonusInterval: TimeInterval
        let roundDuration: TimeInterval
    }

    var phase: Phase = .menu
    var bugs: [Bug] = []
    var score = 0
    var hits = 0
    var misses = 0
    var timeRemaining: TimeInterval = 0

    private var configuration = Configuration(
        speedMultiplier: 1,
        maximumBugCount: 8,
        bonusInterval: 5,
        roundDuration: 30
    )
    private var lastUpdate = Date()
    private var spawnElapsed: TimeInterval = 0
    private var rareSpawnElapsed: TimeInterval = 0

    var accuracy: Int {
        let attempts = hits + misses
        guard attempts > 0 else { return 0 }
        return Int((Double(hits) / Double(attempts) * 100).rounded())
    }

    // MARK: - Round

    func start(with settings: GameSettings) {
        configuration = Configuration(
            speedMultiplier: CGFloat(0.55 + settings.speed * 0.11),
            maximumBugCount: Int(settings.maxCockroaches),
            bonusInterval: settings.bonusInterval,
            roundDuration: settings.roundDuration
        )
        score = 0
        hits = 0
        misses = 0
        timeRemaining = settings.roundDuration
        spawnElapsed = 0
        rareSpawnElapsed = 0
        lastUpdate = Date()
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
        phase = .results
    }

    func showMenu() {
        bugs.removeAll()
        phase = .menu
    }

    // MARK: - Update

    func update(at date: Date) {
        guard phase == .playing else { return }

        let elapsed = min(max(date.timeIntervalSince(lastUpdate), 0), 0.1)
        lastUpdate = date
        timeRemaining = max(0, timeRemaining - elapsed)

        guard timeRemaining > 0 else {
            finish()
            return
        }

        moveBugs(elapsed: elapsed)
        spawnElapsed += elapsed
        rareSpawnElapsed += elapsed

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
    }

    func handleTap(at point: CGPoint) {
        guard phase == .playing else { return }

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
        } else {
            misses += 1
            score -= 3
        }
    }

    // MARK: - Movement

    private func moveBugs(elapsed: TimeInterval) {
        for index in bugs.indices {
            var bug = bugs[index]
            let distance = bug.speed * configuration.speedMultiplier * CGFloat(elapsed)
            var x = bug.position.x + bug.velocity.dx * distance
            var y = bug.position.y + bug.velocity.dy * distance
            let margin = bug.size / 2

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

    private func makeBug(type: BugType) -> Bug {
        let margin = type.size / 2
        let angle = CGFloat.random(in: 0...(2 * .pi))
        return Bug(
            position: CGPoint(
                x: CGFloat.random(in: margin...(1 - margin)),
                y: CGFloat.random(in: margin...(1 - margin))
            ),
            velocity: CGVector(dx: cos(angle), dy: sin(angle)),
            type: type
        )
    }
}
