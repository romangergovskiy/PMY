import Foundation
import Observation

@Observable
final class AppState {
    var selectedPlayer: PlayerProfile? {
        didSet {
            UserDefaults.standard.set(selectedPlayer?.id.uuidString, forKey: Self.storageKey)
        }
    }

    func restoreSelection(from profiles: [PlayerProfile]) {
        guard selectedPlayer == nil, !profiles.isEmpty else { return }
        if let stored = UserDefaults.standard.string(forKey: Self.storageKey),
           let id = UUID(uuidString: stored),
           let match = profiles.first(where: { $0.id == id }) {
            selectedPlayer = match
        } else {
            selectedPlayer = profiles.first
        }
    }

    private static let storageKey = "selectedPlayerID"
}
