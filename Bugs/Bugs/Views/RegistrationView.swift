import SwiftUI

struct RegistrationView: View {

    // MARK: - Properties

    @State private var fullName = ""
    @State private var gender: Gender = .male
    @State private var course = 1
    @State private var difficulty = 5.0
    @State private var birthDate = Calendar.current.date(byAdding: .year, value: -18, to: Date()) ?? Date()
    @State private var player: Player?
    @State private var showsNameError = false

    private let courses = Array(1...6)
    private let locale = Locale(identifier: "ru_RU")

    private var dateRange: ClosedRange<Date> {
        let minDate = Calendar.current.date(from: DateComponents(year: 1960, month: 1, day: 1)) ?? Date.distantPast
        return minDate...Date()
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 16) {
                        header
                        nameCard
                        genderCard
                        courseCard
                        difficultyCard
                        birthdayCard
                        submitButton
                        if let player {
                            resultCard(player)
                                .id("result")
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .padding(.bottom, 24)
                }
                .onChange(of: player) { _, newValue in
                    guard newValue != nil else { return }
                    DispatchQueue.main.async {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            proxy.scrollTo("result", anchor: .center)
                        }
                    }
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .background(Palette.background.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
        }
        .tint(Palette.accent)
        .environment(\.locale, locale)
    }

    // MARK: - Subviews

    private var header: some View {
        HStack(spacing: 14) {
            Image(systemName: "ant.fill")
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(Palette.gold)
                .frame(width: 56, height: 56)
                .background(Palette.accent, in: RoundedRectangle(cornerRadius: 16, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text("Жуки")
                    .font(.title.bold())
                    .foregroundStyle(Palette.ink)
                Text("Регистрация игрока")
                    .font(.subheadline)
                    .foregroundStyle(Palette.muted)
            }

            Spacer()
        }
        .padding(.top, 8)
        .padding(.bottom, 4)
    }

    private var nameCard: some View {
        FormCard(title: "ФИО") {
            TextField("Иванов Иван Иванович", text: $fullName)
                .textContentType(.name)
                .textInputAutocapitalization(.words)
                .submitLabel(.done)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(Palette.field, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                .onChange(of: fullName) { _, _ in
                    showsNameError = false
                }

            if showsNameError {
                Text("Введите фамилию, имя и отчество")
                    .font(.footnote)
                    .foregroundStyle(.red)
            }
        }
    }

    private var genderCard: some View {
        FormCard(title: "Пол") {
            HStack(spacing: 18) {
                ForEach(Gender.allCases) { option in
                    RadioButton(
                        title: option.title,
                        isSelected: gender == option
                    ) {
                        gender = option
                    }
                }
                Spacer(minLength: 0)
            }
        }
    }

    private var courseCard: some View {
        FormCard(title: "Курс") {
            Menu {
                ForEach(courses, id: \.self) { value in
                    Button("\(value) курс") {
                        course = value
                    }
                }
            } label: {
                HStack {
                    Text("\(course) курс")
                        .foregroundStyle(Palette.ink)
                    Spacer()
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Palette.muted)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(Palette.field, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
    }

    private var difficultyCard: some View {
        FormCard(title: "Уровень сложности") {
            VStack(spacing: 10) {
                Slider(value: $difficulty, in: 1...10, step: 1)
                    .tint(Palette.accent)

                HStack {
                    Text("Лёгкий")
                    Spacer()
                    Text("\(Int(difficulty))")
                        .font(.headline.monospacedDigit())
                        .foregroundStyle(Palette.accent)
                    Spacer()
                    Text("Сложный")
                }
                .font(.caption)
                .foregroundStyle(Palette.muted)
            }
        }
    }

    private var birthdayCard: some View {
        FormCard(title: "Дата рождения") {
            DatePicker(
                "Дата рождения",
                selection: $birthDate,
                in: dateRange,
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .labelsHidden()
            .tint(Palette.accent)
        }
    }

    private var submitButton: some View {
        Button(action: register) {
            Text("Зарегистрировать")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
        }
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.roundedRectangle(radius: 14))
        .controlSize(.large)
    }

    private func resultCard(_ player: Player) -> some View {
        FormCard(title: "Данные игрока") {
            Text(player.detailsText)
                .font(.body)
                .foregroundStyle(Palette.ink)
                .frame(maxWidth: .infinity, alignment: .leading)
                .textSelection(.enabled)

            VStack(spacing: 10) {
                Text("Знак зодиака")
                    .font(.caption.weight(.semibold))
                    .tracking(0.6)
                    .foregroundStyle(Palette.muted)

                Image(player.zodiacSign.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 168, height: 168)
                    .accessibilityLabel(player.zodiacSign.title)

                Text(player.zodiacSign.title)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(Palette.ink)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 8)
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    // MARK: - Actions

    private func register() {
        let name = fullName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else {
            withAnimation(.easeInOut(duration: 0.2)) {
                showsNameError = true
                player = nil
            }
            return
        }

        withAnimation(.easeInOut(duration: 0.25)) {
            showsNameError = false
            player = Player(
                fullName: name,
                gender: gender,
                course: course,
                difficulty: Int(difficulty),
                birthDate: birthDate,
                zodiacSign: ZodiacSign.from(birthDate: birthDate)
            )
        }
    }
}

// MARK: - Radio

private struct RadioButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .stroke(Palette.accent, lineWidth: 2)
                        .frame(width: 22, height: 22)
                    if isSelected {
                        Circle()
                            .fill(Palette.accent)
                            .frame(width: 12, height: 12)
                    }
                }
                Text(title)
                    .foregroundStyle(Palette.ink)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Card

private struct FormCard<Content: View>: View {
    let title: String
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title.uppercased())
                .font(.caption.weight(.semibold))
                .tracking(0.8)
                .foregroundStyle(Palette.muted)
            content
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Palette.card, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 10, y: 3)
    }
}

#Preview {
    RegistrationView()
}
