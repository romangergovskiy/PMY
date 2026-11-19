import Foundation
import Observation

@Observable
final class AppContainer {
    let settings = GameSettings()
    let appState = AppState()
    let goldRate = GoldRateStore()
    let game = GameViewModel()
}
