import SwiftData
import SwiftUI

struct RecordsView: View {

    // MARK: - Properties

    @Environment(\.modelContext) private var modelContext
    @Query(
        sort: [
            SortDescriptor(\GameRecord.score, order: .reverse),
            SortDescriptor(\GameRecord.createdAt, order: .reverse)
        ]
    )
    private var records: [GameRecord]

    // MARK: - Body

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                ScreenHeader(
                    systemImage: "trophy.fill",
                    title: "Рекорды",
                    subtitle: "Лучшие результаты игроков"
                )
                .padding(.horizontal, 20)
                .padding(.top, 12)

                if records.isEmpty {
                    emptyState
                } else {
                    recordsList
                }
            }
            .background(Palette.background.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .onAppear(perform: collapseDuplicates)
        }
    }

    private var emptyState: some View {
        FormCard(title: "Результаты") {
            VStack(spacing: 12) {
                Image(systemName: "trophy")
                    .font(.system(size: 48))
                    .foregroundStyle(Palette.gold)
                Text("Сыграйте первый раунд")
                    .font(.headline)
                    .foregroundStyle(Palette.ink)
                Text("После завершения игры результат автоматически сохранится здесь.")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Palette.muted)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 20)
        .frame(maxHeight: .infinity, alignment: .top)
    }

    private var recordsList: some View {
        List {
            ForEach(Array(records.enumerated()), id: \.element.id) { index, record in
                RecordRow(position: index + 1, record: record)
                    .listRowInsets(EdgeInsets(top: 6, leading: 20, bottom: 6, trailing: 20))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            delete(record)
                        } label: {
                            Label("Удалить", systemImage: "trash")
                        }
                    }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }

    private func delete(_ record: GameRecord) {
        modelContext.delete(record)
        try? modelContext.save()
    }

    private func collapseDuplicates() {
        var bestByPlayer: [UUID: GameRecord] = [:]
        var extras: [GameRecord] = []

        for record in records {
            let key = record.player?.id ?? record.id
            if let current = bestByPlayer[key] {
                if record.score > current.score
                    || (record.score == current.score && record.createdAt > current.createdAt) {
                    extras.append(current)
                    bestByPlayer[key] = record
                } else {
                    extras.append(record)
                }
            } else {
                bestByPlayer[key] = record
            }
        }

        guard !extras.isEmpty else { return }
        extras.forEach(modelContext.delete)
        try? modelContext.save()
    }
}

// MARK: - Row

private struct RecordRow: View {
    let position: Int
    let record: GameRecord

    var body: some View {
        HStack(spacing: 14) {
            Text("\(position)")
                .font(.title2.bold().monospacedDigit())
                .foregroundStyle(position <= 3 ? Palette.gold : Palette.muted)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 5) {
                Text(record.playerName)
                    .font(.headline)
                    .foregroundStyle(Palette.ink)

                Text("Сложность \(record.difficulty) · Попадания \(record.hits) · Промахи \(record.misses)")
                    .font(.caption)
                    .foregroundStyle(Palette.muted)

                Text(Self.dateFormatter.string(from: record.createdAt))
                    .font(.caption2)
                    .foregroundStyle(Palette.muted)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("\(record.score)")
                    .font(.title2.bold().monospacedDigit())
                    .foregroundStyle(Palette.accent)
                Text("очков")
                    .font(.caption2)
                    .foregroundStyle(Palette.muted)
            }
        }
        .padding(14)
        .background(Palette.card, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 10, y: 3)
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMM yyyy, HH:mm"
        return formatter
    }()
}

#Preview {
    RecordsView()
        .modelContainer(for: [PlayerProfile.self, GameRecord.self], inMemory: true)
}
