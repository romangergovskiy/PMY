import Foundation
import Observation

@Observable
final class GameSettings {
    var speed = 5.0
    var maxCockroaches = 8.0
    var bonusInterval = 5.0
    var roundDuration = 30.0
}
