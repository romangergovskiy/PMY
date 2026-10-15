import SwiftUI

struct SettingsView: View {

    // MARK: - Properties

    @Environment(GameSettings.self) private var settings

    // MARK: - Body

    var body: some View {
        @Bindable var settings = settings

        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    ScreenHeader(
                        systemImage: "slider.horizontal.3",
                        title: "Настройки",
                        subtitle: "Параметры игры"
                    )

                    FormCard(title: "Скорость игры") {
                        SettingsSlider(
                            value: $settings.speed,
                            range: 1...10,
                            step: 1,
                            leading: "Медленно",
                            trailing: "Быстро",
                            text: "\(Int(settings.speed))"
                        )
                    }

                    FormCard(title: "Максимальное количество тараканов на экране") {
                        SettingsSlider(
                            value: $settings.maxCockroaches,
                            range: 3...20,
                            step: 1,
                            leading: "3",
                            trailing: "20",
                            text: "\(Int(settings.maxCockroaches))"
                        )
                    }

                    FormCard(title: "Интервал появления бонусов") {
                        SettingsSlider(
                            value: $settings.bonusInterval,
                            range: 1...15,
                            step: 1,
                            leading: "Чаще",
                            trailing: "Реже",
                            text: "\(Int(settings.bonusInterval)) с"
                        )
                    }

                    FormCard(title: "Длительность раунда") {
                        SettingsSlider(
                            value: $settings.roundDuration,
                            range: 15...120,
                            step: 5,
                            leading: "15 с",
                            trailing: "120 с",
                            text: "\(Int(settings.roundDuration)) с"
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .padding(.bottom, 24)
            }
            .background(Palette.background.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Slider

private struct SettingsSlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    let leading: String
    let trailing: String
    let text: String

    var body: some View {
        VStack(spacing: 10) {
            Slider(value: $value, in: range, step: step)
                .tint(Palette.accent)
                .accessibilityIdentifier("pager-lock-slider")

            HStack {
                Text(leading)
                Spacer()
                Text(text)
                    .font(.headline.monospacedDigit())
                    .foregroundStyle(Palette.accent)
                Spacer()
                Text(trailing)
            }
            .font(.caption)
            .foregroundStyle(Palette.muted)
        }
    }
}

#Preview {
    SettingsView()
        .environment(GameSettings())
}
