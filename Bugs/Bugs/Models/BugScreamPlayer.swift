import AVFoundation
import AudioToolbox
import Foundation

enum BugScreamPlayer {
    private static var player: AVAudioPlayer?

    static func play() {
        stop()
        if let url = Bundle.main.url(forResource: "scream", withExtension: "wav") {
            try? AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try? AVAudioSession.sharedInstance().setActive(true)
            player = try? AVAudioPlayer(contentsOf: url)
            player?.numberOfLoops = -1
            player?.volume = 1
            player?.play()
            return
        }

        AudioServicesPlaySystemSound(1016)
    }

    static func stop() {
        player?.stop()
        player = nil
    }
}
