import Foundation
import Observation
import SwiftData

@Observable
final class GameViewModel {
    let session = GameSession()
    let tilt = TiltController()
    var didSaveResult = false

    func tick(at date: Date, player: PlayerProfile?, modelContext: ModelContext) {
        let previousPhase = session.phase
        session.update(at: date, gravity: tilt.gravity)
        syncTiltAudio()

        if previousPhase != .results, session.phase == .results {
            saveResultIfNeeded(player: player, modelContext: modelContext)
        }
    }

    func handleTap(at point: CGPoint) {
        _ = session.handleTap(at: point)
        syncTiltAudio()
    }

    func startRound(settings: GameSettings, goldPoints: Int) {
        didSaveResult = false
        tilt.stop()
        BugScreamPlayer.stop()
        session.start(with: settings, goldPoints: goldPoints)
    }

    func showMenu() {
        tilt.stop()
        BugScreamPlayer.stop()
        session.showMenu()
    }

    func saveResultIfNeeded(player: PlayerProfile?, modelContext: ModelContext) {
        guard !didSaveResult, let player else { return }
        didSaveResult = true

        let existing = player.records.sorted { lhs, rhs in
            if lhs.score == rhs.score {
                return lhs.createdAt > rhs.createdAt
            }
            return lhs.score > rhs.score
        }

        if let best = existing.first {
            if session.score >= best.score {
                best.createdAt = Date()
                best.score = session.score
                best.hits = session.hits
                best.misses = session.misses
                best.accuracy = session.accuracy
                best.difficulty = player.difficulty
                best.playerName = player.fullName
            }
            for extra in existing.dropFirst() {
                modelContext.delete(extra)
            }
        } else {
            let record = GameRecord(
                score: session.score,
                hits: session.hits,
                misses: session.misses,
                accuracy: session.accuracy,
                difficulty: player.difficulty,
                player: player
            )
            modelContext.insert(record)
        }

        try? modelContext.save()
    }

    private func syncTiltAudio() {
        if session.phase != .playing {
            tilt.stop()
            BugScreamPlayer.stop()
            return
        }

        if session.tiltUnlocked, !tilt.isActive {
            tilt.start()
            BugScreamPlayer.play()
        } else if !session.tiltUnlocked, tilt.isActive {
            tilt.stop()
            BugScreamPlayer.stop()
        }
    }
}
