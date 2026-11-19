import Foundation
import SwiftData

@Model
final class GameRecord {
    @Attribute(.unique) var id: UUID
    var createdAt: Date
    var score: Int
    var hits: Int
    var misses: Int
    var accuracy: Int
    var difficulty: Int
    var playerName: String
    var player: PlayerProfile?

    init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        score: Int,
        hits: Int,
        misses: Int,
        accuracy: Int,
        difficulty: Int,
        player: PlayerProfile
    ) {
        self.id = id
        self.createdAt = createdAt
        self.score = score
        self.hits = hits
        self.misses = misses
        self.accuracy = accuracy
        self.difficulty = difficulty
        self.playerName = player.fullName
        self.player = player
    }
}
