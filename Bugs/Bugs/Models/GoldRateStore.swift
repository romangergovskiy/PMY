import Foundation
import Observation

@Observable
final class GoldRateStore {
    var quote: GoldQuote?
    var isLoading = false
    var errorMessage: String?

    init() {
        quote = GoldQuoteCache.load()
    }

    var points: Int {
        quote?.points() ?? 100
    }

    func refresh() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let quote = try await GoldRateClient.fetch()
            self.quote = quote
            GoldQuoteCache.save(quote)
            errorMessage = nil
        } catch {
            if quote == nil {
                quote = GoldQuoteCache.load()
            }
            errorMessage = "Не удалось загрузить курс золота ЦБ"
        }
    }
}
