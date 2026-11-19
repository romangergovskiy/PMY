import SwiftUI
import SwiftData

enum AppTab: Int, CaseIterable, Hashable {
    case game
    case registration
    case records
    case rules
    case authors
    case settings

    var title: String {
        switch self {
        case .game:
            return "Игра"
        case .registration:
            return "Игрок"
        case .records:
            return "Рекорды"
        case .rules:
            return "Правила"
        case .authors:
            return "Авторы"
        case .settings:
            return "Настройки"
        }
    }

    var systemImage: String {
        switch self {
        case .game:
            return "gamecontroller.fill"
        case .registration:
            return "person.crop.circle.fill"
        case .records:
            return "trophy.fill"
        case .rules:
            return "book.fill"
        case .authors:
            return "person.2.fill"
        case .settings:
            return "slider.horizontal.3"
        }
    }
}

struct RootTabView: View {

    // MARK: - Properties

    @State private var selectedTab: AppTab = .game

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $selectedTab) {
                ForEach(AppTab.allCases, id: \.self) { tab in
                    page(for: tab)
                        .tag(tab)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            AppTabBar(selection: selectedTab) { tab in
                withAnimation(.easeInOut(duration: 0.2)) {
                    selectedTab = tab
                }
            }
        }
        .background(Palette.background.ignoresSafeArea())
    }

    // MARK: - Screens

    @ViewBuilder
    private func page(for tab: AppTab) -> some View {
        switch tab {
        case .game:
            GameView { tab in
                withAnimation(.easeInOut(duration: 0.2)) {
                    selectedTab = tab
                }
            }
        case .registration:
            RegistrationView()
        case .records:
            RecordsView()
        case .rules:
            RulesView()
        case .authors:
            AuthorsView()
        case .settings:
            SettingsView()
        }
    }
}

// MARK: - Tab bar

private struct AppTabBar: View {
    let selection: AppTab
    let onSelect: (AppTab) -> Void

    var body: some View {
        HStack(spacing: 4) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                Button {
                    onSelect(tab)
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: tab.systemImage)
                            .font(.system(size: 15, weight: .semibold))
                        Text(tab.title)
                            .font(.system(size: 9, weight: .medium))
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    .foregroundStyle(selection == tab ? Palette.accent : Palette.ink.opacity(0.7))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background {
                        if selection == tab {
                            Capsule()
                                .fill(Palette.field)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(6)
        .background(Palette.card, in: Capsule())
        .shadow(color: .black.opacity(0.08), radius: 12, y: 4)
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 6)
    }
}

#Preview {
    RootTabView()
        .environment(GameSettings())
        .environment(AppState())
        .environment(GoldRateStore())
        .environment(GameViewModel())
        .modelContainer(for: [PlayerProfile.self, GameRecord.self], inMemory: true)
}
