import SwiftUI
import WidgetKit

struct GoldRateEntry: TimelineEntry {
    let date: Date
    let quote: GoldQuote?
}

struct GoldRateProvider: TimelineProvider {
    func placeholder(in context: Context) -> GoldRateEntry {
        GoldRateEntry(date: Date(), quote: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (GoldRateEntry) -> Void) {
        if let cached = GoldQuoteCache.load() {
            completion(GoldRateEntry(date: Date(), quote: cached))
            return
        }

        Task {
            let quote = try? await GoldRateClient.fetch()
            if let quote {
                GoldQuoteCache.save(quote)
            }
            completion(GoldRateEntry(date: Date(), quote: quote))
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<GoldRateEntry>) -> Void) {
        Task {
            var quote = GoldQuoteCache.load()
            do {
                let fresh = try await GoldRateClient.fetch()
                quote = fresh
                GoldQuoteCache.save(fresh)
            } catch {
                // Keep the last successful quote if the network is unavailable.
            }

            let entry = GoldRateEntry(date: Date(), quote: quote)
            let next = Calendar.current.date(byAdding: .minute, value: 15, to: Date()) ?? Date().addingTimeInterval(900)
            completion(Timeline(entries: [entry], policy: .after(next)))
        }
    }
}

struct GoldSphereView: View {
    let entry: GoldRateEntry

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 1, green: 0.93, blue: 0.62),
                            Color(red: 0.93, green: 0.72, blue: 0.18),
                            Color(red: 0.62, green: 0.42, blue: 0.08)
                        ],
                        center: UnitPoint(x: 0.32, y: 0.28),
                        startRadius: 6,
                        endRadius: 92
                    )
                )
                .overlay {
                    Circle()
                        .stroke(Color.white.opacity(0.35), lineWidth: 3)
                }
                .shadow(color: Color.orange.opacity(0.45), radius: 10, y: 4)

            VStack(spacing: 3) {
                Text("Au ЦБ")
                    .font(.caption2.weight(.bold))
                    .tracking(0.8)
                if let quote = entry.quote {
                    Text(quote.compactValue)
                        .font(.title2.bold().monospacedDigit())
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                    Text("₽/г · \(quote.shortDate)")
                        .font(.caption2.weight(.semibold))
                } else {
                    Text("Нет курса")
                        .font(.caption.weight(.semibold))
                }
            }
            .foregroundStyle(Color(red: 0.28, green: 0.16, blue: 0.04))
            .padding(16)
        }
        .padding(8)
        .containerBackground(for: .widget) {
            Color(red: 0.12, green: 0.16, blue: 0.10)
        }
    }
}

struct GoldRateWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "GoldRateWidget", provider: GoldRateProvider()) { entry in
            GoldSphereView(entry: entry)
        }
        .configurationDisplayName("Курс золота ЦБ")
        .description("Учётная цена золота Банка России в форме шара.")
        .supportedFamilies([.systemSmall])
    }
}

#Preview(as: .systemSmall) {
    GoldRateWidget()
} timeline: {
    GoldRateEntry(date: Date(), quote: GoldQuote(value: 10199.63, date: Date()))
    GoldRateEntry(date: Date(), quote: nil)
}
