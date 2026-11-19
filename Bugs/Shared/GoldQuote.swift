import Foundation

struct GoldQuote: Codable, Equatable, Sendable {
    var value: Double
    var date: Date

    var formattedValue: String {
        Self.priceFormatter.string(from: NSNumber(value: value)) ?? String(format: "%.2f", value)
    }

    var compactValue: String {
        Self.compactFormatter.string(from: NSNumber(value: value)) ?? String(format: "%.0f", value)
    }

    var formattedDate: String {
        Self.dateFormatter.string(from: date)
    }

    var shortDate: String {
        Self.shortDateFormatter.string(from: date)
    }

    func points() -> Int {
        max(20, Int((value / 80.0).rounded()))
    }

    private static let priceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter
    }()

    private static let compactFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        formatter.groupingSeparator = " "
        return formatter
    }()

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.timeZone = TimeZone(identifier: "Europe/Moscow")
        formatter.dateFormat = "d MMM yyyy"
        return formatter
    }()

    private static let shortDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.timeZone = TimeZone(identifier: "Europe/Moscow")
        formatter.dateFormat = "dd.MM"
        return formatter
    }()
}

enum GoldQuoteCache {
    private static let key = "cbrGoldQuote"

    static func save(_ quote: GoldQuote) {
        guard let data = try? JSONEncoder().encode(quote) else { return }
        AppGroup.defaults.set(data, forKey: key)
        UserDefaults.standard.set(data, forKey: key)
        if let url = fileURL {
            try? data.write(to: url, options: .atomic)
        }
    }

    static func load() -> GoldQuote? {
        let blobs = [
            AppGroup.defaults.data(forKey: key),
            UserDefaults.standard.data(forKey: key),
            fileURL.flatMap { try? Data(contentsOf: $0) }
        ]

        for data in blobs {
            if let data, let quote = try? JSONDecoder().decode(GoldQuote.self, from: data) {
                return quote
            }
        }
        return nil
    }

    private static var fileURL: URL? {
        FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: AppGroup.id)?
            .appendingPathComponent("gold-quote.json")
    }
}
