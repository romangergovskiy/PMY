import SwiftUI
import SwiftData

@main
struct BugsApp: App {
    @State private var container = AppContainer()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environment(container)
                .environment(container.settings)
                .environment(container.appState)
                .environment(container.goldRate)
                .environment(container.game)
                .tint(Palette.accent)
                .environment(\.locale, Locale(identifier: "ru_RU"))
                .task {
                    await container.goldRate.refresh()
                }
        }
        .modelContainer(for: [PlayerProfile.self, GameRecord.self])
    }
}
