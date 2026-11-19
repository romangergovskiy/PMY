import Foundation

enum GoldRateClient {
    static let endpoint = URL(string: "https://www.cbr.ru/scripts/xml_metall.asp")!

    static func fetch(now: Date = Date()) async throws -> GoldQuote {
        let url = makeURL(now: now)
        var request = URLRequest(url: url)
        request.timeoutInterval = 20
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.setValue(
            "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148",
            forHTTPHeaderField: "User-Agent"
        )
        request.setValue("application/xml, text/xml, */*", forHTTPHeaderField: "Accept")

        let (data, response) = try await URLSession.shared.data(for: request)
        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            throw GoldRateError.http(http.statusCode)
        }

        guard let quote = parse(data: data) else {
            throw GoldRateError.empty
        }
        return quote
    }

    static func parse(data: Data) -> GoldQuote? {
        guard let xml = decodeXML(data) else { return nil }
        return parseRecords(in: xml)
    }

    private static func makeURL(now: Date) -> URL {
        let calendar = Calendar(identifier: .gregorian)
        let from = calendar.date(byAdding: .day, value: -21, to: now) ?? now
        let fromText = queryDate.string(from: from)
        let toText = queryDate.string(from: now)
        return URL(string: "https://www.cbr.ru/scripts/xml_metall.asp?date_req1=\(fromText)&date_req2=\(toText)") ?? endpoint
    }

    private static func decodeXML(_ data: Data) -> String? {
        if let utf8 = String(data: data, encoding: .utf8), utf8.contains("Record") {
            return utf8
        }

        let cf = CFStringEncoding(CFStringEncodings.windowsCyrillic.rawValue)
        let encoding = String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(cf))
        return String(data: data, encoding: encoding)
    }

    private static func parseRecords(in xml: String) -> GoldQuote? {
        let pattern = #"Record Date="([0-9]{2}\.[0-9]{2}\.[0-9]{4})"\s+Code="1">\s*<Buy>([^<]*)</Buy>\s*<Sell>([^<]*)</Sell>"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive, .dotMatchesLineSeparators]) else {
            return nil
        }

        let range = NSRange(xml.startIndex..., in: xml)
        var latest: GoldQuote?

        regex.enumerateMatches(in: xml, options: [], range: range) { match, _, _ in
            guard
                let match,
                let dateRange = Range(match.range(at: 1), in: xml),
                let buyRange = Range(match.range(at: 2), in: xml),
                let sellRange = Range(match.range(at: 3), in: xml),
                let date = recordDate.date(from: String(xml[dateRange]))
            else { return }

            let sell = parseNumber(String(xml[sellRange]))
            let buy = parseNumber(String(xml[buyRange]))
            guard let value = sell ?? buy else { return }

            if latest == nil || date >= latest!.date {
                latest = GoldQuote(value: value, date: date)
            }
        }

        return latest
    }

    private static func parseNumber(_ raw: String) -> Double? {
        let normalized = raw
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\u{00a0}", with: "")
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: ",", with: ".")
        return Double(normalized)
    }

    private static let queryDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "Europe/Moscow")
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter
    }()

    private static let recordDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "Europe/Moscow")
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter
    }()
}

enum GoldRateError: Error {
    case invalidURL
    case http(Int)
    case empty
}
