import Combine
import SwiftUI

struct GameView: View {

    // MARK: - Properties

    @Environment(GameSettings.self) private var settings
    @State private var session = GameSession()

    let onNavigate: (AppTab) -> Void

    private let timer = Timer.publish(
        every: 1.0 / 30.0,
        on: .main,
        in: .common
    ).autoconnect()

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Group {
                switch session.phase {
                case .menu:
                    menu
                case .playing:
                    game
                case .results:
                    results
                }
            }
            .background(Palette.background.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
        }
        .onReceive(timer) { date in
            session.update(at: date)
        }
    }

    // MARK: - Menu

    private var menu: some View {
        ScrollView {
            VStack(spacing: 16) {
                ScreenHeader(
                    systemImage: "ant.fill",
                    title: "Жуки",
                    subtitle: "Поймай их всех"
                )

                FormCard(title: "Игровой раунд") {
                    VStack(spacing: 18) {
                        Image(BugType.common.assetName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 104, height: 104)
                            .shadow(color: Palette.accent.opacity(0.22), radius: 8, y: 5)

                        Text("Нажимай на насекомых, набирай очки и старайся не промахиваться.")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(Palette.muted)

                        Button {
                            session.start(with: settings)
                        } label: {
                            Label("Начать игру", systemImage: "play.fill")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                        }
                        .buttonStyle(.borderedProminent)
                        .buttonBorderShape(.roundedRectangle(radius: 14))
                    }
                    .frame(maxWidth: .infinity)
                }

                FormCard(title: "Меню") {
                    VStack(spacing: 10) {
                        MenuButton(title: "Настройки", systemImage: "slider.horizontal.3") {
                            onNavigate(.settings)
                        }
                        MenuButton(title: "Авторы", systemImage: "person.2.fill") {
                            onNavigate(.authors)
                        }
                        MenuButton(title: "Правила игры", systemImage: "book.fill") {
                            onNavigate(.rules)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .padding(.bottom, 24)
        }
    }

    // MARK: - Game

    private var game: some View {
        VStack(spacing: 12) {
            HStack(spacing: 10) {
                HUDItem(
                    title: "Время",
                    value: "\(Int(ceil(session.timeRemaining)))",
                    systemImage: "timer"
                )
                HUDItem(
                    title: "Очки",
                    value: "\(session.score)",
                    systemImage: "star.fill"
                )
                HUDItem(
                    title: "Промахи",
                    value: "\(session.misses)",
                    systemImage: "xmark.circle.fill"
                )
            }

            gameField

            Text("Нажимай на жуков. Промах: −3 очка")
                .font(.footnote)
                .foregroundStyle(Palette.muted)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
    }

    private var gameField: some View {
        GeometryReader { proxy in
            let size = proxy.size
            let unit = min(size.width, size.height)

            ZStack {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.82, green: 0.90, blue: 0.77),
                                Color(red: 0.67, green: 0.80, blue: 0.59)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                ForEach(session.bugs) { bug in
                    BugSprite(bug: bug)
                        .frame(width: bug.size * unit, height: bug.size * unit)
                        .position(
                            x: bug.position.x * size.width,
                            y: bug.position.y * size.height
                        )
                }
            }
            .contentShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .gesture(
                SpatialTapGesture()
                    .onEnded { value in
                        guard size.width > 0, size.height > 0 else { return }
                        session.handleTap(
                            at: CGPoint(
                                x: value.location.x / size.width,
                                y: value.location.y / size.height
                            )
                        )
                    }
            )
            .overlay {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(Palette.accent.opacity(0.35), lineWidth: 2)
            }
        }
    }

    // MARK: - Results

    private var results: some View {
        ScrollView {
            VStack(spacing: 16) {
                ScreenHeader(
                    systemImage: "flag.checkered",
                    title: "Раунд завершён",
                    subtitle: "Результаты игры"
                )

                FormCard(title: "Итог") {
                    VStack(spacing: 18) {
                        Text("\(session.score)")
                            .font(.system(size: 64, weight: .bold, design: .rounded))
                            .foregroundStyle(Palette.accent)

                        Text("очков")
                            .font(.headline)
                            .foregroundStyle(Palette.muted)

                        HStack(spacing: 10) {
                            ResultItem(title: "Попадания", value: "\(session.hits)")
                            ResultItem(title: "Промахи", value: "\(session.misses)")
                            ResultItem(title: "Точность", value: "\(session.accuracy)%")
                        }

                        Button {
                            session.start(with: settings)
                        } label: {
                            Label("Играть ещё раз", systemImage: "arrow.clockwise")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                        }
                        .buttonStyle(.borderedProminent)
                        .buttonBorderShape(.roundedRectangle(radius: 14))

                        Button("Вернуться в меню") {
                            session.showMenu()
                        }
                        .foregroundStyle(Palette.accent)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .padding(.bottom, 24)
        }
    }
}

// MARK: - Bug

private struct BugSprite: View {
    let bug: Bug

    var body: some View {
        Image(bug.assetName)
            .resizable()
            .interpolation(.high)
            .scaledToFit()
            .shadow(color: .black.opacity(0.28), radius: 3, y: 2)
            .rotationEffect(
                .radians(
                    atan2(Double(bug.velocity.dy), Double(bug.velocity.dx)) + .pi / 2
                )
            )
            .accessibilityLabel("\(bug.type.title), \(bug.points) очков")
    }
}

// MARK: - Components

private struct HUDItem: View {
    let title: String
    let value: String
    let systemImage: String

    var body: some View {
        VStack(spacing: 4) {
            Label(title, systemImage: systemImage)
                .font(.caption2)
                .foregroundStyle(Palette.muted)
            Text(value)
                .font(.title3.bold().monospacedDigit())
                .foregroundStyle(Palette.ink)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Palette.card, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

private struct ResultItem: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.title2.bold().monospacedDigit())
                .foregroundStyle(Palette.ink)
            Text(title)
                .font(.caption2)
                .foregroundStyle(Palette.muted)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Palette.field, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

private struct MenuButton: View {
    let title: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: systemImage)
                    .frame(width: 24)
                Text(title)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.bold())
            }
            .foregroundStyle(Palette.ink)
            .padding(12)
            .background(Palette.field, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    GameView(onNavigate: { _ in })
        .environment(GameSettings())
}
