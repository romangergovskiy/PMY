import SwiftUI

@main
struct BugsApp: App {
    @State private var settings = GameSettings()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environment(settings)
                .tint(Palette.accent)
                .environment(\.locale, Locale(identifier: "ru_RU"))
        }
    }
}
