import Foundation

enum AppGroup {
    static let id = "group.com.romangergovskiy.Bugs"

    static var defaults: UserDefaults {
        UserDefaults(suiteName: id) ?? .standard
    }
}
