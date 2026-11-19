import SwiftUI
import SwiftData

struct RegistrationView: View {

    // MARK: - Properties

    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState
    @Query(sort: \PlayerProfile.fullName) private var profiles: [PlayerProfile]

    @State private var fullName = ""
    @State private var gender: Gender = .male
    @State private var course = 1
    @State private var difficulty = 5.0
    @State private var birthDate = Calendar.current.date(byAdding: .year, value: -18, to: Date()) ?? Date()
    @State private var player: Player?
    @State private var showsNameError = false
    @State private var databaseError: String?
    @State private var playerToDelete: PlayerProfile?

    private let courses = Array(1...6)

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
                        savedPlayersCard
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
            .onAppear {
                appState.restoreSelection(from: profiles)
                if let selected = appState.selectedPlayer, player == nil {
                    select(selected)
                }
            }
            .confirmationDialog(
                "Удалить игрока?",
                isPresented: Binding(
                    get: { playerToDelete != nil },
                    set: { if !$0 { playerToDelete = nil } }
                ),
                titleVisibility: .visible
            ) {
                Button("Удалить", role: .destructive) {
                    if let playerToDelete {
                        delete(playerToDelete)
                    }
                }
                Button("Отмена", role: .cancel) {
                    playerToDelete = nil
                }
            } message: {
                Text("Рекорды этого игрока тоже будут удалены.")
            }
        }
    }

    // MARK: - Subviews

    private var header: some View {
        ScreenHeader(
            systemImage: "ant.fill",
            title: "Жуки",
            subtitle: "Регистрация игрока"
        )
    }

    private var savedPlayersCard: some View {
        FormCard(title: "Сохранённые игроки") {
            if profiles.isEmpty {
                Text("Зарегистрируйте первого игрока")
                    .foregroundStyle(Palette.muted)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(profiles.enumerated()), id: \.element.id) { index, profile in
                        if index > 0 {
                            Divider()
                        }
                        playerRow(profile)
                    }
                }
            }
        }
    }

    private func playerRow(_ profile: PlayerProfile) -> some View {
        HStack(spacing: 12) {
            Button {
                select(profile)
            } label: {
                HStack(spacing: 10) {
                    Image(
                        systemName: appState.selectedPlayer?.id == profile.id
                            ? "checkmark.circle.fill"
                            : "person.crop.circle"
                    )
                    .foregroundStyle(Palette.accent)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(profile.fullName)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Palette.ink)
                            .multilineTextAlignment(.leading)
                        Text("Сложность \(profile.difficulty)")
                            .font(.caption)
                            .foregroundStyle(Palette.muted)
                    }

                    Spacer()
                }
            }
            .buttonStyle(.plain)

            Button {
                playerToDelete = profile
            } label: {
                Image(systemName: "trash")
                    .foregroundStyle(.red)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Удалить \(profile.fullName)")
        }
        .padding(.vertical, 10)
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

            if let databaseError {
                Text(databaseError)
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
                    .accessibilityIdentifier("pager-lock-slider")

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

        let zodiacSign = ZodiacSign.from(birthDate: birthDate)
        let newProfile = PlayerProfile(
            fullName: name,
            gender: gender,
            course: course,
            difficulty: Int(difficulty),
            birthDate: birthDate,
            zodiacSign: zodiacSign
        )

        modelContext.insert(newProfile)

        do {
            try modelContext.save()
            databaseError = nil
            appState.selectedPlayer = newProfile

            withAnimation(.easeInOut(duration: 0.25)) {
                showsNameError = false
                player = Player(
                    fullName: name,
                    gender: gender,
                    course: course,
                    difficulty: Int(difficulty),
                    birthDate: birthDate,
                    zodiacSign: zodiacSign
                )
            }
        } catch {
            modelContext.delete(newProfile)
            databaseError = "Не удалось сохранить игрока"
        }
    }

    private func select(_ profile: PlayerProfile) {
        appState.selectedPlayer = profile
        fullName = profile.fullName
        gender = profile.gender
        course = profile.course
        difficulty = Double(profile.difficulty)
        birthDate = profile.birthDate
        player = Player(
            fullName: profile.fullName,
            gender: profile.gender,
            course: profile.course,
            difficulty: profile.difficulty,
            birthDate: profile.birthDate,
            zodiacSign: profile.zodiacSign
        )
    }

    private func delete(_ profile: PlayerProfile) {
        let deletedID = profile.id
        let remaining = profiles.filter { $0.id != deletedID }

        if appState.selectedPlayer?.id == deletedID {
            appState.selectedPlayer = remaining.first
        }

        modelContext.delete(profile)

        do {
            try modelContext.save()
            databaseError = nil
            playerToDelete = nil

            if let next = appState.selectedPlayer {
                select(next)
            } else {
                resetForm()
            }
        } catch {
            databaseError = "Не удалось удалить игрока"
            playerToDelete = nil
        }
    }

    private func resetForm() {
        fullName = ""
        gender = .male
        course = 1
        difficulty = 5.0
        birthDate = Calendar.current.date(byAdding: .year, value: -18, to: Date()) ?? Date()
        player = nil
        showsNameError = false
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

#Preview {
    RegistrationView()
        .environment(AppState())
        .modelContainer(for: [PlayerProfile.self, GameRecord.self], inMemory: true)
}
