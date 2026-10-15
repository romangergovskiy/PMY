import SwiftUI

struct RulesView: View {

    // MARK: - Properties

    private let html = Self.loadHTML()

    // MARK: - Body

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                ScreenHeader(
                    systemImage: "book.fill",
                    title: "Правила",
                    subtitle: "Как играть"
                )
                .padding(.horizontal, 20)
                .padding(.top, 12)

                if let html {
                    HTMLView(html: html)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Palette.card, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .shadow(color: .black.opacity(0.06), radius: 10, y: 3)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 16)
                } else {
                    FormCard(title: "Правила") {
                        Text("Не удалось загрузить файл правил из ресурсов проекта.")
                            .foregroundStyle(Palette.ink)
                    }
                    .padding(.horizontal, 20)
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(Palette.background.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Loading

    private static func loadHTML() -> String? {
        guard let url = Bundle.main.url(forResource: "Rules", withExtension: "html") else {
            return nil
        }
        return try? String(contentsOf: url, encoding: .utf8)
    }
}

#Preview {
    RulesView()
}
